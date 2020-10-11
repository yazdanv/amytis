//
//  Switch.swift
//  Alamofire
//
//  Created by Yazdan on 6/30/17.
//

import UIKit
import JavaScriptCore

public class Switch: UISwitch, AmytisViewType, ExtendableView {
    
    /////////////////////// extendable view protocol
    public var params: [String : Any] = [:]
    ////////////////////////////////////////////////
    
    //////////////////////////// coded view protocol
    var _id: String!
    public var id: String {
        get {return _id}
        set {_id = newValue}
    }
    var _frame: Frame!
    public var frame2: Frame {
        get {return _frame}
        set {_frame = newValue}
    }
    var _parent: AmytisView!
    public var parent: AmytisView {
        get {return _parent}
        set {_parent = newValue}
    }
    var _viewXML: XML!
    public var viewXML: XML {
        get {return _viewXML}
        set {_viewXML = newValue}
    }
    public func requiredInit() {
        
    }
    @objc public func reRenderWithChild(_ xml: String) {_reRender(xml)}
    @objc public func reRender(_ params: [String: Any]) {_reRender(params)}
    @objc public func reCalculateFrame(_ animated: Bool) {_reCalculateFrame(animated)}
    @objc public func animateToFrame(_ string: String, _ time: Double = 0.5, _ completion: JSValue? = nil) {
        _ = animateToFrame(string, time, {_ = completion?.call(withArguments: [])})
    }
    ///////////////////////////////////////////////
    
    var _onSelect: ((Bool) -> Void)?
    var _on: (() -> Void)?
    var _off: (() -> Void)?
    
    convenience init(_ parent: AmytisView, _ rect: Frame, _ object: XML) {
        self.init(frame: CGRect(origin: rect.origin, size: rect.size))
        self.setViewParams(object, parent)
        self.parent = parent
        self.viewXML = object
        self.config()
        self.frame2 = rect
        self.addTarget(self, action: #selector(statusChanged), for: .valueChanged)
        frame2.rotate = {self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin}
    }
    
    func empty() {
        frame2.empty()
    }
    
    public func config() {
        viewXML.yes(topParams.status, {
            setOn(true, animated: true)
        })
    }
    
    public func onSelect(action: @escaping (Bool) -> Void) {
        self._onSelect = action
    }
    
    public func off(action: @escaping () -> Void) {
        self._off = action
    }
    public func on(action: @escaping () -> Void) {
        self._on = action
    }
    
    @objc func statusChanged() {
        if self.isOn {
            _on?()
        } else {
            _off?()
        }
        _onSelect?(self.isOn)
    }
    
}


///// js wrapper

@objc public protocol SwitchJSExport: JSExport {
    func onSelect(_ action: JSValue)
    func isOff(_ action: JSValue)
    func isOn(_ action: JSValue)
    func off()
    func on()
    var status: Bool {get set}
}

extension Switch: SwitchJSExport {
    
    public var status: Bool {
        get {
            return self.isOn
        }
        set {
            self.setOn(newValue, animated: true)
        }
    }
    
    public func onSelect(_ action: JSValue) {self._onSelect = {st in action.call(withArguments: [st])}}
    public func isOff(_ action: JSValue) {self._off = {action.call(withArguments: [])}}
    public func isOn(_ action: JSValue) {self._on = {action.call(withArguments: [])}}
    
    public func off() {self.setOn(false, animated: true)}
    public func on() {self.setOn(true, animated: true)}
    
}
