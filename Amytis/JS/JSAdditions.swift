//
//  JSAdditions.swift
//  Pods
//
//  Created by Yazdan on 4/25/17.
//
//

import Foundation
import JavaScriptCore

let timerJSSharedInstance = TimerJS()

@objc public protocol TimerJSExport : JSExport {
    
    func setTimeout(_ callback : JSValue,_ ms : Double) -> String
    
    func clearTimeout(_ identifier: String)
    
    func setInterval(_ callback : JSValue,_ ms : Double) -> String
    
    func log(_ val: Any)
    
    func exit()
    
    func JSRequest(_ url: String, _ method: String, _ parameters: [String: Any], _ done: JSValue, _ failure: JSValue)
    
}

// Custom class must inherit from `NSObject`
@objc class TimerJS: NSObject, TimerJSExport {
    var timers = [String: Timer]()
    var jsVal: JSValue!
    
    static func registerInto(jsContext: JSContext?, forKeyedSubscript: String = "timerJS") {
        if let jsContext = jsContext {
            jsContext.setObject(timerJSSharedInstance,
                                forKeyedSubscript: forKeyedSubscript as (NSCopying & NSObjectProtocol))
            jsContext.evaluateScript(
                "function setTimeout(callback, ms) {" +
                    "    return timerJS.setTimeout(callback, ms)" +
                    "}" +
                    "function clearTimeout(indentifier) {" +
                    "    timerJS.clearTimeout(indentifier)" +
                    "}" +
                    "function setInterval(callback, ms) {" +
                    "    return timerJS.setInterval(callback, ms)" +
                "}"
            )
        }
    }
    
    func log(_ val: Any) {
        dm.log("LOG : \(val)")
    }
    
    func exit() {
        Darwin.exit(0)
    }
    
    func JSRequest(_ url: String, _ method: String, _ parameters: [String: Any], _ done: JSValue, _ failure: JSValue) {
        let coding: DataCoding = .urlEncoded
        if method == "post" {
            RH.postStr(url, parameters, coding: coding, success: {
                done.call(withArguments: [$0])
            }, failed: {
                failure.call(withArguments: [])
            })
        } else {
            RH.getStr(url, parameters, success: {
                done.call(withArguments: [$0])
            }, failed: {
                failure.call(withArguments: [])
            })
        }
    }
    
    func clearTimeout(_ identifier: String) {
        let timer = timers.removeValue(forKey: identifier)
        
        timer?.invalidate()
    }
    
    
    func setInterval(_ callback: JSValue,_ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms, repeats: true)
    }
    
    func setTimeout(_ callback: JSValue, _ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms , repeats: false)
    }
    
    func createTimer(callback: JSValue, ms: Double, repeats : Bool) -> String {
        let timeInterval  = ms/1000.0
        self.jsVal = callback
        let uuid = NSUUID().uuidString
        
        // make sure that we are queueing it all in the same executable queue...
        // JS calls are getting lost if the queue is not specified... that's what we believe... ;)
        DispatchQueue.main.async(execute: {
            let timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                             target: self,
                                             selector: #selector(self.todo),
                                             userInfo: callback,
                                             repeats: repeats)
            self.timers[uuid] = timer
        })
        
        
        return uuid
    }
    
    @objc func todo() {
        jsVal.call(withArguments: [])
    }
}
