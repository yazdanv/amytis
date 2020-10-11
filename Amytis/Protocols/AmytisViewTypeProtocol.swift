//
//  AmytisViewTypeProtocol.swift
//  Alamofire
//
//  Created by Yazdan on 7/18/17.
//

import Foundation
import JavaScriptCore

@objc public protocol AmytisViewType: JSExport {
    var id: String {get set}
    var parent: AmytisView {get set}
    var viewXML: XML {get set}
    var frame2: Frame {get set}
    
    func config()
    func reCalculateFrame(_ animated: Bool)
    
    func animateToFrame(_ string: String, _ time: Double, _ completion: JSValue?)
    
    func reRender(_ params: [String: Any])
    func reRenderWithChild(_ xml: String)
    
    
    func requiredInit()
}

public extension AmytisViewType where Self: UIView {
    
    public init(_ aview: AmytisView, id: String? = nil) {
        self.init(frame: CGRect.zero)
        self.parent = aview
        viewXML = XML(name: "view", attributes: [:])
        if let id = id {
            aview.views[id] = self
        }
        aview.view.addSubview(self)
        requiredInit()
    }
    
    public init(_ view: UIView, id: String? = nil) {
        self.init(frame: CGRect.zero)
        self.parent = view.createAmytisView()
        viewXML = XML(name: "view", attributes: [:])
        if let id = id {
            self.parent.views[id] = self
        }
        self.parent.view.addSubview(self)
        requiredInit()
    }
    
    func changeParameter(_ value: String, _ keys: [String], _ shouldReRender: Bool = true) {
        var found = false
        for item in keys {
            if viewXML.attributes[item] != nil {
                found = true
                viewXML.attributes[item] = value
            }
        }
        if !found {viewXML.attributes[keys[0]] = value}
        if shouldReRender {reRender()}
    }
    
    func setFrame() {
        self.frame2 = Frame.create(from: viewXML, withParent: parent.view, Aview: parent)
        self.frame2.rotate = {self.frame = self.frame2.rect}
        self.frame = self.frame2.rect
    }
    
    public func frame(_ string: String) -> Self {
        viewXML.attributes[viewParams.frame[0]] = string
        setFrame()
        return self
    }
    
    public func frame(_ frm: Frame) -> Self {
        self.frame2 = frm
        self.frame2.rotate = {self.frame = self.frame2.rect}
        self.frame = self.frame2.rect
        return self
    }
    
    public func padding(_ padding: String) -> Self {
        changeParameter(padding, viewParams.padding, false)
        setFrame()
        return self
    }
    
    public func backgroundColor(_ string: String) -> Self {
        self.backgroundColor = UIColor.pickColor(string)
        return self
    }

    public func backgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    public func hidden(_ _isHidden: Bool = true) -> Self {
        self.isHidden = _isHidden
        return self
    }
    
    public func elevation(_ elevation: Double) -> Self {
        self.clipsToBounds = true
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: -2, height: 3);
        self.layer.shadowRadius = CGFloat(elevation)
        self.layer.shadowOpacity = Float(0.1 * elevation)
        return self
    }
    
    public func corner(_ corner: Double) -> Self {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(corner)
        return self
    }
    
    public func circle() -> Self {
        let rect = self.frame
        let computedSize = CGSize(width: CGFloat((rect.width + rect.height) / 2), height: CGFloat((rect.width + rect.height) / 2))
        self.frame = CGRect(origin: CGPoint(x: rect.origin.x - CGFloat((computedSize.width - rect.width) / 2), y: rect.origin.y - CGFloat((computedSize.height - rect.height) / 2)), size: computedSize)
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(computedSize.width/2)
        return self
    }
    
//    public func animateToFrame(_ string: String) -> Self {
//        return animateToFrame(string, 0.5)
//    }
//    
//    public func animateToFrame(_ string: String, _ time: Double) -> Self {
//        return animateToFrame(string, time)
//    }
//    
//    public func animateToFrame(_ string: String, _ time: Double, _ completion: (() -> Void)) -> Self {
//        return animateToFrame(string, time, completion)
//    }
    


    
    public func animateToFrame(_ string: String, _ time: Double = 0.5, _ completion: (() -> Void)? = nil) -> Self {
        viewXML.attributes[viewParams.frame[0]] = string
        UIView.animate(withDuration: time, animations: {
            self.setFrame()
        }, completion: {done in
            completion?()
        })
        return self
    }
    
    func _reRender(_ xml: String) {
        do {
            let xm = try XMLDocument(xml: "<item>\(xml)</item>").root
            viewXML.children = xm.children
            viewXML.value = xm.value
            self.config()
            self.setViewParams(viewXML, parent)
        } catch {}
    }
    
    func _reRender(_ params: [String: Any]) {
        for (key, val) in params {
            if let v = val as? String {
                viewXML.attributes[key] = v
            }
        }
        self.config()
        self.setViewParams(viewXML, parent)
    }
    
    func reRender() {
        self.config()
        self.setViewParams(viewXML, parent)
    }
    
    
    /////////// recalculate size
    
    public func _reCalculateFrame(_ animated: Bool) {
        let frame = Frame.create(from: viewXML, withParent: parent.view, Aview: parent)
        self.frame2 = frame
        if animated {
            UIView.animate(withDuration: parent.reCalculateAnimateTime, animations: {
                self.frame = frame.rect
                self.setViewParams(self.viewXML, self.parent)
            })
        } else {
            self.frame = frame.rect
            self.setViewParams(viewXML, parent)
        }
    }
}
