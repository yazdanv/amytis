//
//  JSController.swift
//  Pods
//
//  Created by Yazdan on 4/25/17.
//
//

import Foundation
import JavaScriptCore

class JSController: NSObject {
    
    var view: AmytisView!
    var context: JSContext?
    
    deinit {
        view = nil
        context = nil
    }
    
    init(_ view: AmytisView) {
        super.init()
        self.view = view
        self.context = {
            let context = JSContext()

            
            let setArgument = {(name: String, object: Any) in
                _ = context?.evaluateScript("var \(name);\nfunction set\(name)(obj){\(name)=obj;}")
                let setView = context?.objectForKeyedSubscript("set\(name)")
                _ = setView?.call(withArguments: [object])
                //context?.setObject(object, forKeyedSubscript: name as (NSCopying & NSObjectProtocol)!)
            }
            
            setArgument("view", view)
            setArgument("controller", view.controller)
            let lists: [[String: Any]] = [view.views]
            for list in lists {
                for (key, obj) in list {
                    setArgument(key, obj)
                }
            }
            return context
        }()
    }
    
    func execute(_ xm: XML?, _ params: [String: Any], _ done: (() -> Void)? = nil) {
        if let xml = xm {
            if xml.str != "", let ctx = context {
                let code = xml.str
                let setArgument = {(name: String, object: Any) in
                    _ = ctx.evaluateScript("var \(name);\nfunction set\(name)(obj){\(name)=obj;}")
                    let setView = ctx.objectForKeyedSubscript("set\(name)")
                    _ = setView?.call(withArguments: [object])
                    //context?.setObject(object, forKeyedSubscript: name as (NSCopying & NSObjectProtocol)!)
                }
                setArgument("params", params)
                _ = ctx.evaluateScript(code)
            }
        }
        if let done = done {
            done()
        }
    }
    
    func run(_ code: String) {
        if let ctx = context {
            print(ctx.evaluateScript(code))
        }
    }
    
}
