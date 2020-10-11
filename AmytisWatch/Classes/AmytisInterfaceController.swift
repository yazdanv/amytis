//
//  AmytisInterfaceController.swift
//  Pods
//
//  Created by Yazdan on 5/31/17.
//
//
import Foundation
import WatchKit
import WatchConnectivity

open class AmytisInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    var watchSession: WCSession!
    
    @IBOutlet open weak var image: WKInterfaceImage!
    
    
    override open func awake(withContext context: Any?) {
        super.awake(withContext: context)
        watchSession = WCSession.default
        if (WCSession.isSupported()) {
            watchSession.delegate = self
            watchSession.activate()
        }
        if image != nil {
            _sendMessage(param.getViewImage, message: [viewParams.height[0]: 380, viewParams.width[0]: 240])
        }
        interfaceLoaded(context: context)
    }
    
    open func interfaceLoaded(context: Any?) {}
    open func sessionActivated() {}
    open func onMessage(_ event: String, _ message: [String: Any], reply: (([String : Any]) -> Void)? = nil) {}

    
    func _sendMessage(_ event: String, message: [String: Any]? = nil, reply: (([String : Any]) -> Void)? = nil, asData: Bool = false) {
        if watchSession.activationState == .activated {
            var msg = [param.event: event] as [String : Any]
            if let message = message {
                msg[param.data] = message
            }
            if asData {
                let data = NSKeyedArchiver.archivedData(withRootObject: msg)
                watchSession.sendMessageData(data, replyHandler: nil, errorHandler: nil)
            } else {
                watchSession.sendMessage(msg, replyHandler: nil, errorHandler: nil)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {self._sendMessage(event, message: message, reply: reply)})
        }
    }
    
    public func sendMessage(_ event: String, message: [String: Any]? = nil, reply: (([String : Any]) -> Void)? = nil, asData: Bool = false) {
        let events = [param.getXml, param.getViewImage]
        if !events.contains(event) {
            _sendMessage(event, message: message, reply: reply, asData: asData)
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleMessage(message: message)
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handleMessage(message: message, reply: replyHandler)
    }
    
    public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let message = NSKeyedUnarchiver.unarchiveObject(with: messageData) as? [String: Any] {
            handleMessage(message: message)
        }
    }
    
    
    func handleMessage(message: [String: Any], reply: (([String: Any]) -> Void)? = nil) {
        if let event = message[param.event] as? String {
            if let data = message[param.data] as? [String: Any] {
                switch event {
                case param.getXml:
                    print("getxml")
                case param.updateImage:
                    if let img = data[imageParams.source[0]] as? UIImage {
                        self.image.setImage(img)
                    }
                default:
                    self.onMessage(event, data, reply: reply)
                }
            } else {
                self.onMessage(event, [:], reply: reply)
            }
        }
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation did complete")
        sessionActivated()
    }
    
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        print(session.isReachable)
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("watch received app context: ", applicationContext)
    }
}
