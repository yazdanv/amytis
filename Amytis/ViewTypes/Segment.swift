//
//  Segment.swift
//  Pods
//
//  Created by Yazdan on 6/3/17.
//
//

import UIKit
import JavaScriptCore

public class Segment: UISegmentedControl, AmytisViewType, ExtendableView {
    

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
    
    public var action: ((Int) -> Void)?
    var views: [Int: String] = [:]
    var lastSelected: Int = 0
    
    convenience init( _ parent: AmytisView, _ rect: Frame, _ object: XML) {
        var segms: [String] = []
        var vs: [Int: String] = [:]
        if let segments = object["segment"].all {
            var i = 0
            for segment in segments {
                segment.string(textParams.text, {text in
                    segms.append(text)
                })
                segment.string([viewParams.id], {id in
                    vs[i] = id
                })
                i += 1
            }
        }
        self.init(items: segms)
        self.setViewParams(object, parent)
        self.parent = parent
        self.views = vs
        self.viewXML = object
        self.selectedSegmentIndex = 0
        runAsync {
            self.frame = rect.rect
            for i in 0...(segms.count - 1) {
                self.setTitle(segms[i], forSegmentAt: i)
            }
        }
        self.frame2 = rect
        config()
        frame2.rotate = {self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin}
    }
    
    func empty() {

    }
    
    public func config() {
        
        self.addTarget(self, action: #selector(changed), for: .valueChanged)
        
        parent.swipe.right {
            if self.selectedSegmentIndex > 0 {
                var toHide: [String] = []
                for (key, value) in self.views {
                    if key != self.selectedSegmentIndex - 1 {
                        toHide.append(value)
                    }
                }
                if let toShow = self.views[self.selectedSegmentIndex - 1] {
                    self.selectedSegmentIndex -= 1
                    self.parent.animateViews(toShow, toHide, right: false, speed: 20)
                }
            }
        }
        
        parent.swipe.left {
            if self.selectedSegmentIndex < self.numberOfSegments - 1 {
                var toHide: [String] = []
                for (key, value) in self.views {
                    if key != self.selectedSegmentIndex + 1 {
                        toHide.append(value)
                    }
                }
                if let toShow = self.views[self.selectedSegmentIndex + 1] {
                    self.selectedSegmentIndex += 1
                    self.parent.animateViews(toShow, toHide, right: true, speed: 20)
                }
            }
        }
        
        viewXML.int(["index"]) {vl in
            self.selectedSegmentIndex = vl - 1
        }
    }
    
    @objc func changed() {
        var toHide: [String] = []
        for (key, value) in views {
            if key != self.selectedSegmentIndex {
                toHide.append(value)
            }
        }
        let right = lastSelected < selectedSegmentIndex ? true : false
        if let toShow = views[self.selectedSegmentIndex] {
            self.parent.animateViews(toShow, toHide, right: right, speed: 20)
            lastSelected = selectedSegmentIndex
        }
        if let ac = action {
            ac(self.selectedSegmentIndex)
        }
    }
    
}
