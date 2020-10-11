//
//  AmytisWatchManager.swift
//  Amytis-iOS
//
//  Created by Yazdan Vakili on 12/16/17.
//

import Foundation
import WatchConnectivity


public protocol AmytisWatchDelegate {
    func onMessage(event: String, message: [String: Any], reply: (([String: Any]) -> Void)?)
}

public class AmytisWatchManager: NSObject, WCSessionDelegate {
    
    var watchSession: WCSession!
    
    var onMessage: ((String, [String: Any], (([String: Any]) -> Void)?) -> Void)?
    public func onMessage(_ action: @escaping ((String, [String: Any], (([String: Any]) -> Void)?) -> Void)) {self.onMessage = action}
    
    public var delegate: AmytisWatchDelegate? {didSet{self.onMessage(delegate!.onMessage)}}
    
    override init() {
        super.init()
        watchSession = WCSession.default
        watchSession.delegate = self
        watchSession.activate()
    }
    
    func _sendMessage(_ event: String, message: [String: Any]? = nil, reply: (([String : Any]) -> Void)? = nil, asData: Bool = false) {
        if watchSession.activationState == .activated, watchSession.isReachable {
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
            watchSession.activate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {self._sendMessage(event, message: message, reply: reply)})
        }
    }
    
    public func sendMessage(_ event: String, message: [String: Any]? = nil, reply: (([String : Any]) -> Void)? = nil, asData: Bool = false) {
        let events = [param.getXml]
        if !events.contains(event) {
            _sendMessage(event, message: message, reply: reply, asData: asData)
        }
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activation complete")
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        print(session.isReachable)
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let event = message[param.event] as? String {
            if let data = message[param.data] as? [String: Any] {
                switch event {
                case param.getXml:
                    print("getxml")
                case param.getViewImage:
                    if let height = data[viewParams.height[0]] as? CGFloat, let width = data[viewParams.width[0]] as? CGFloat {
                        self.watchViewArea = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                        self.watchAView = self.watchViewArea.createAmytisView(viewDidLoad: {})
                    }
                default:
                    self.onMessage?(event, data, nil)
                }
            } else {
                self.onMessage?(event, [:], nil)
            }
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let event = message[param.event] as? String {
            if let data = message[param.data] as? [String: Any] {
                self.onMessage?(event, data, replyHandler)
            } else {
                self.onMessage?(event, [:], replyHandler)
            }
        }
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("session did become inactive")
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        print("session did deactivate")
    }
    
    //////////
    
    var watchViewArea: UIView!
    var watchAView: AmytisView!
}

extension AmytisWatchManager {
    
    func updateView() {
        UIGraphicsBeginImageContextWithOptions(watchAView.view.frame.size, false, 0);
        watchAView.view.drawHierarchy(in: CGRect(x: 0, y: 0, width: watchAView.view.frame.size.width, height: watchAView.view.frame.size.height), afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        _sendMessage(param.updateImage, message: [imageParams.source[0]: image])
    }
    
}


