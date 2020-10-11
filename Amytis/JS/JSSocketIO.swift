////
////  JSSocketIO.swift
////  Pods
////
////  Created by Yazdan on 5/10/17.
////
////
//
//import Foundation
////import SocketIO
//import JavaScriptCore
//
//@objc public protocol JSSocketIOProtocol: JSExport {
//    static func create(_ url: String) -> JSSocketIO
//    func on(_ event: String, _ callback: JSValue)
//    func emit(_ event: String, _ data: Any)
//    func connect()
//}
//
//public class JSSocketIO: NSObject, JSSocketIOProtocol {
//
////    var socket: SocketIOClient?
//
//    init(_ url: String) {
//        super.init()
//        let configs: SocketIOClientConfiguration = [.log(false), .forcePolling(true)]
//        if let ur = URL(string: url) {
////            socket = SocketIOClient(socketURL: ur, config: [.log(false), .forcePolling(true)])
//            let m = SocketManager(socketURL: ur, config: [.log(false), .forcePolling(true)])
//            socket = m.defaultSocket
//        }
//    }
//
//    public func on(_ event: String, _ callback: JSValue) {
//        if let s = socket {
//            s.on(event, callback: {data, ack in
//                callback.call(withArguments: [data, ack])
//            })
//        }
//    }
//
//    public func emit(_ event: String, _ data: Any) {
//        if let s = socket {
//            s.emit(event, String(describing: data))
//        }
//    }
//
//    public func connect() {
//        if let s = socket {
//            s.connect()
//        }
//    }
//
//    public class func create(_ url: String) -> JSSocketIO {
//        return JSSocketIO(url)
//    }
//
//}
