//
//  SocketConnection.swift
//  HooshmandSazan
//
//  Created by Yazdan Vakili on 12/6/17.
//  Copyright © 2017 Yazdan. All rights reserved.
//

import Foundation


public protocol SocketConnectionDelegate {
    func onString(string: String)
}

public enum SocketResult: Int {
    case notConnected = -2
    case waiting = -1
    case success = 1
    case unknown = 2
}

public class SocketConnection: NSObject, StreamDelegate {

    public var isConnected: Bool {
        return inOpen && outOpen
    }
    
    public var delegate: SocketConnectionDelegate?
    
    public var bufferSize = 8192
    
    public func onString(action: @escaping ((String) -> Void)) {self.onMsg = action}
    public func onData(action: @escaping ((Data) -> Void)) {self.onData = action}
    
    public func onConnected(action: @escaping (() -> Void)) {self.connected = action}
    public func onDisconnected(action: @escaping (() -> Void)) {self.disconnected = action}
    
    
    private var wasOpened = false
    private var wasClosed = false
    
    private var inOpen: Bool = false
    private var inStream: InputStream? = nil
    
    private var outOpen: Bool = false
    private var outStream: OutputStream? = nil
    
    private var hasSpace: Bool = true
    
    private var connected: (() -> Void)?
    private var disconnected: (() -> Void)?
    private var failed: (() -> Void)?
    
    private var autoReconnect: Bool = true
    private var connectTimeout: Double = 60.0
    private var readTimeout: Double = 0.02
    private var retries: Int = 10
    private var tries: Int = 0
    private var sendDelay: Double = 0
    
    private var host: String!
    private var port: Int!
    
    private var sendOnConnect = false
    private var processQ: [[UInt8]] = []
    
//    public required override init() {}
    
    public convenience init(_ host: String, _ port: Int, _ bufferSize: Int = 8192, connected: (() -> Void)? = nil, disconnected: (() -> Void)? = nil, autoReconnect: Bool = true, readTimeout: Double = 0.02, sendDelay: Double = 0, sendOnConnect: Bool = true, retries: Int = 10) {
        self.init()
        self.host = host
        self.port = port
        self.bufferSize = bufferSize
        self.autoReconnect = autoReconnect
        self.connected = connected
        self.disconnected = disconnected
        self.readTimeout = readTimeout
        self.sendDelay = sendDelay
        self.sendOnConnect = sendOnConnect
        self.retries = retries
    }

    public func connect(failed: (() -> Void)? = nil, connected: (() -> Void)? = nil, disconnected: (() -> Void)? = nil, timeout: Double = 60.0) {
        q.async {
            self.wasClosed = false
            self.wasOpened = false
            if disconnected != nil || connected != nil || failed != nil {
                self.tries = 0
            }
            self.connectTimeout = timeout
            if let c = connected {self.connected = c}
            if let d = disconnected {self.disconnected = d}
            self.failed = failed
            Stream.getStreamsToHost(withName: self.host, port: self.port, inputStream: &self.inStream, outputStream: &self.outStream)
            self.inStream!.delegate = self
            self.outStream!.delegate = self
            self.inStream!.schedule(in: .main, forMode: RunLoop.Mode.default)
            self.outStream!.schedule(in: .main, forMode: RunLoop.Mode.default)
            self.q.asyncAfter(deadline: .now() + timeout, execute: {
                if !self.isConnected {
                    self._disconnected()
                    self.inStream!.close()
                    self.outStream!.close()
                }
            })
            self.inStream!.open()
            self.outStream!.open()
        }
    }
    
    public func disconnect() {
        autoReconnect = false
        _disconnected()
        q.async {
            self.inStream!.close()
            self.outStream!.close()
            self.autoReconnect = true
        }
    }
    
    public func reconnect() {
//        if !isConnected {
            q.async {
                self.connect(timeout: self.connectTimeout)
            }
//        }
    }
    
    private func send(_bytes: [UInt8]) -> SocketResult {
        if isConnected  {
            if outStream!.hasSpaceAvailable, sendDelay == 0 {
                if sendDelay == 0 {
                    let r = outStream!.write(_bytes, maxLength: _bytes.count)
                    hasSpace = false
                    if r > 0 {
                        return .success
                    } else {
                        return .unknown
                    }
                } else {
                    processQ.append(_bytes)
                    q.async {self.process()}
                    return .waiting
                }
            } else {
                processQ.append(_bytes)
                q.async {self.process()}
                return .waiting
            }
        } else {
            return .notConnected
        }
    }
    
    public func send(byte: UInt8) -> SocketResult {
        return send(_bytes: [byte])
    }
    
    public func send(bytes: [UInt8]) -> SocketResult {
        return send(_bytes: bytes)
    }

    public func send(array: [Any]) -> SocketResult {
        var _bytes: [UInt8] = []
        for item in array {
            if let str = item as? String {
                for char in str.utf8 {
                    _bytes.append(char)
                }
            } else if let bt = item as? Int {
                _bytes.append(UInt8(bt))
            } else if let bt = item as? UInt8 {
                _bytes.append(bt)
            } else if let bt = item as? Double {
                _bytes.append(UInt8(bt))
            }
        }
        return send(_bytes: _bytes)
    }
    
    public func send(string: String) -> SocketResult {
        return send(_bytes: [UInt8](string.utf8))
    }
    
    public func send(data: Data) -> SocketResult {
        var _bytes: [UInt8] = []
        for byte in data {
            _bytes.append(byte)
        }
        return send(_bytes: _bytes)
    }
    
    public func send(int: Int) -> SocketResult {
        return send(_bytes: [UInt8(int)])
    }
    
    func _connected() {
        self.tries = 0
        self.wasOpened = true
        self.wasClosed = false
        self.runAsync {
            self.connected?()
        }
        if sendOnConnect {_ = self.outStream!.hasSpaceAvailable}
    }
    
    func _disconnected() {
        self.wasClosed = true
        self.wasOpened = false
        self.runAsync {
            if let failed = self.failed {
                failed()
            } else {
                self.disconnected?()
            }
        }
        tries += 1
        if autoReconnect, tries <= retries {
            self.reconnect()
        }
    }
    
    private var startedProcess = false

    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if aStream === inStream {
            switch eventCode {
            case Stream.Event.errorOccurred:
                print("input: ErrorOccurred: \(String(describing: aStream.streamError))")
                self.inOpen = false
                if self.wasOpened {
                    self._disconnected()
                } else if !self.wasClosed {
                    self._disconnected()
                }
            case Stream.Event.openCompleted:
//                print("input: OpenCompleted")
                self.inOpen = true
                if outOpen {
                    self._connected()
                }
            case Stream.Event.hasBytesAvailable:
//                print("input: HasBytesAvailable")
                if (self.inOpen) {
                    q.async {
                        var data: Data = Data()
                        var read = 1
                        var times = 0
                        while (read > 0 && times < 100) {
                            if let ins = self.inStream, ins.hasBytesAvailable {
                                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: self.bufferSize)
                                read = ins.read(buffer, maxLength: self.bufferSize - 1)
                                if read > 0 {
                                    data.append(buffer, count: read)
                                }
                                buffer.deallocate(capacity: self.bufferSize)
                            } else {
                                times += 1
                                usleep(UInt32(10000 * self.readTimeout))
                            }
                        }
                        self._onData(data)
                        if let str = String(data: data, encoding: .utf8), str != "" {
                            self._onMsg(str)
                        }
                    }
                }
            default:
                break
            }
        }
        else if aStream === outStream {
            switch eventCode {
            case Stream.Event.errorOccurred:
                print("output: ErrorOccurred: \(String(describing: aStream.streamError))")
                self.outOpen = false
                if self.wasOpened {
                    self._disconnected()
                } else if !self.wasClosed {
                    self._disconnected()
                }
            case Stream.Event.openCompleted:
//                print("output: OpenCompleted")
                self.outOpen = true
                if inOpen {
                    self._connected()
                }
            case Stream.Event.hasSpaceAvailable:
                hasSpace = true
//                print("output: HasSpaceAvailable")
                q.async {self.process()}
            default:
                break
            }
        }
    }
    
    func process() {
        if outStream!.hasSpaceAvailable, let _bytes = processQ.first {
            outStream!.write(_bytes, maxLength: _bytes.count)
            hasSpace = false
            if processQ.count > 0 {
                if processQ.count < 2 {
                    processQ.removeAll()
                } else {
                    processQ.remove(at: 0)
                }
            }
            if sendDelay > 0 {
                q.asyncAfter(deadline: .now() + sendDelay, execute: {
                    self.process()
                })
            } else {
                process()
            }
        }
    }

    private var _until: [String: (String) -> Void] = [:]
    public func until(until u: String, timeout: Double = 1.0, _ action: @escaping (String) -> Void, _ failed: (() -> Void)? = nil) {
        _until[u] = action
        q.asyncAfter(deadline: .now() + timeout) {
            if self._until[u] != nil {
                self._until.removeValue(forKey: u)
                failed?()
            }
        }
    }

    private func _onMsg(_ msg: String) {
        if msg != "" {
            self.runAsync {
                self.onMsg?(msg)
                self.delegate?.onString(string: msg)
            }
            for (u, item) in _until {
                _until[u] = nil
                if (msg + "\n").contains(u) {self.runAsync {item(msg)}}
            }
        }
    }
    
    private func _onData(_ data: Data) {
        self.runAsync {
            self.onData?(data)
        }
    }

    private var onMsg: ((String) -> Void)?
    private var onData: ((Data) -> Void)?
    private var q = DispatchQueue.init(label: "SocketConnectionBackground", qos: DispatchQoS.init(qosClass: DispatchQoS.QoSClass.background, relativePriority: 1), attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
}



///////////// socket connection js wrapper

import JavaScriptCore

@objc public protocol SocketConnectionJSExport: JSExport {
    static func create(_ host: String, _ port: Int, _ parameters: [String: Any]) -> SocketConnection
    func connect(_ parameters: [String: Any])
    func onString(_ action: JSValue)
    func onData(_ action: JSValue)
    func onConnected(_ action: JSValue)
    func onDisconnected(_ action: JSValue)
    func send(_ val: Any)
    func disconnect()
    func reconnect()
}

extension functionParams {
    static let bufferSize = "bufferSize"
    static let connected = "connected"
    static let disconnected = "disconnected"
    static let autoReconnect = "autoReconnect"
    static let readTimeout = "readTimeout"
    static let sendDelay = "sendDelay"
    static let sendOnConnect = "sendOnConnect"
    static let retries = "retries"
    static let failed = "failed"
    static let timeout = "timeout"
}

extension SocketConnection: SocketConnectionJSExport {
    
    public static func create(_ host: String, _ port: Int, _ parameters: [String: Any]) -> SocketConnection {
        var (bufferSize, connected, disconnected, autoReconnect, readTimeout, sendDelay, sendOnConnect, retries): (Int, (() -> Void)?, (() -> Void)?, Bool, Double, Double, Bool, Int) = (32768, nil, nil, true, 0.02, 0, true, 10)
        if let val = parameters[functionParams.bufferSize] as? Int {bufferSize=val}
        if let val = parameters[functionParams.connected] as? JSValue {connected={val.call(withArguments: [])}}
        if let val = parameters[functionParams.disconnected] as? JSValue {disconnected={val.call(withArguments: [])}}
        if let val = parameters[functionParams.autoReconnect] as? Bool {autoReconnect=val}
        if let val = parameters[functionParams.readTimeout] as? Double {readTimeout=val}
        if let val = parameters[functionParams.sendDelay] as? Double {sendDelay=val}
        if let val = parameters[functionParams.sendOnConnect] as? Bool {sendOnConnect=val}
        if let val = parameters[functionParams.retries] as? Int {retries=val}
        return SocketConnection(host.resolveHostname(), port, bufferSize, connected: connected, disconnected: disconnected, autoReconnect: autoReconnect, readTimeout: readTimeout, sendDelay: sendDelay, sendOnConnect: sendOnConnect, retries: retries)
    }
    
    public func connect(_ parameters: [String: Any] = [:]) {
        var (failed, connected, disconnected, timeout): ((() -> Void)?, (() -> Void)?, (() -> Void)?, Double) = (nil, nil, nil, 60.0)
        if let val = parameters[functionParams.failed] as? JSValue {failed={val.call(withArguments: [])}}
        if let val = parameters[functionParams.connected] as? JSValue {connected={val.call(withArguments: [])}}
        if let val = parameters[functionParams.disconnected] as? JSValue {disconnected={val.call(withArguments: [])}}
        if let val = parameters[functionParams.timeout] as? Double {timeout=val}
        connect(failed: failed, connected: connected, disconnected: disconnected, timeout: timeout)
    }
    
    public func onString(_ action: JSValue) {self.onString {val in action.call(withArguments: [val])}}
    public func onData(_ action: JSValue) {self.onData {val in action.call(withArguments: [val])}}
    public func onConnected(_ action: JSValue) {self.onConnected {action.call(withArguments: [])}}
    public func onDisconnected(_ action: JSValue) {self.onDisconnected {action.call(withArguments: [])}}
    
    public func send(_ val: Any) {
        if let v = val as? String {
            _ = send(string: v)
        } else if let v = val as? UInt8 {
            _ = send(byte: v)
        } else if let v = val as? [UInt8] {
            _ = send(bytes: v)
        } else if let v = val as? Int {
            _ = send(int: v)
        } else if let v = val as? [Any] {
            _ = send(array: v)
        } else if let v = val as? Data {
            _ = send(data: v)
        }
    }
    
}
