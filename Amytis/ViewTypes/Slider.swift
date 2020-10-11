//
//  Slider.swift
//  Alamofire
//
//  Created by Yazdan on 10/12/17.
//

import UIKit
import JavaScriptCore

public class Slider: UISlider, AmytisViewType, ExtendableView {
    
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
    
    convenience init(_ parent: AmytisView, _ rect: Frame, _ object: XML) {
        self.init(frame: CGRect(origin: rect.origin, size: rect.size))
        self.setViewParams(object, parent)
        self.frame2 = rect
        self.parent = parent
        self.viewXML = object
        frame2.rotate = {self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin}
    }
    
    public func config() {}
    
}

