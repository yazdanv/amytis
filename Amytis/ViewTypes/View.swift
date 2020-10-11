//
//  View.swift
//  Pods
//
//  Created by Yazdan on 4/20/17.
//
//

import UIKit
import JavaScriptCore

@objc public protocol ViewJsExport: JSExport {
    func captureViewAsImage()
}

public final class View: UIView, AmytisViewType, ExtendableView, ViewJsExport {
    

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
    
    public var AmytisView: AmytisView!
    
    convenience init( _ parent: AmytisView, _ rect: Frame, _ object: XML) {
        self.init(frame: CGRect(origin: rect.origin, size: rect.size))
        self.frame2 = rect
        self.parent = parent
        self.viewXML = object
        self.setViewParams(object, parent)
        self.config()
        frame2.rotate = {self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin}
    }
    
    deinit {
        frame2.empty()
    }
    
    func empty() {
        frame2.empty()
        AmytisView = nil
    }
    
    public func config() {
        if self.viewXML.children.count > 0 {
            var hasScroll = false
            viewXML.int(viewParams.scroll) {val in
                hasScroll = true
                let sc = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                sc.contentSize = CGSize(width: self.frame.width, height: CGFloat(val))
                let v = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat(val)))
                AmytisView = v.createAmytisView(parent: self.parent)
                sc.addSubview(v)
                self.addSubview(sc)
            }
            if !hasScroll {AmytisView = self.createAmytisView(parent: self.parent)}
//            AmytisView.viewDidLoad = {
//                for (key, val) in self.AmytisView.views {
//                    self.parent.views[key] = val
//                }
////                self.parent.viewLoaded()
//            }
            AmytisView.populateWith(xmlArr: self.viewXML.children)
            self.viewXML.xml(topParams.code, {xml in
                self.parent.controller.run(xml.str)
            })
        } else {
//            self.parent.viewLoaded()
        }
    }
    
    public func children(_ action: ((View, AmytisView) -> Void)) -> View {
        AmytisView = self.createAmytisView(parent: self.parent)
        action(self, AmytisView)
        return self
    }
    
    //////// capture view
    
    public func captureViewAsImage() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0);
        self.drawHierarchy(in: CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height), afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    }
    
    //////// AmytisView View extract methods helper
    
    
    public func view(_ id: String) -> View? {
        return AmytisView.view(id)
    }
    
    public func label(_ id: String) -> Label? {
        return AmytisView.label(id)
    }
    
    public func image(_ id: String) -> ImageView? {
        return AmytisView.image(id)
    }
    
    public func button(_ id: String) -> Button? {
        return AmytisView.button(id)
    }
    
    public func textfield(_ id: String) -> TextField? {
        return AmytisView.textfield(id)
    }
    
    public func tableview(_ id: String) -> TableView? {
        return AmytisView.tableview(id)
    }
    
    public func collectionView(_ id: String) -> CollectionView? {
        return AmytisView.collectionview(id)
    }
    
    public func map(_ id: String) -> Map? {
        return AmytisView.map(id)
    }
    
    public func picker(_ id: String) -> Picker? {
        return AmytisView.picker(id)
    }
    
    public func datepicker(_ id: String) -> DatePicker? {
        return AmytisView.datepicker(id)
    }
    
    public func selection(_ id: String) -> Segment? {
        return AmytisView.selection(id)
    }
    
    public func slider(_ id: String) -> Slider? {
        return AmytisView.slider(id)
    }
    
    public func slideshow(_ id: String) -> SlideShow? {
        return AmytisView.slideshow(id)
    }
    
    public func getSwitch(_ id: String) -> Switch? {
        return AmytisView.getSwitch(id)
    }
    
    ///////// using views by closure
    
    public func view(_ id: String, _ closure: @escaping (View) -> Void) {
        AmytisView.view(id, closure)
    }
    
    public func label(_ id: String, _ closure: @escaping (Label) -> Void) {
        AmytisView.label(id, closure)
    }
    
    public func image(_ id: String, _ closure: @escaping (ImageView) -> Void) {
        AmytisView.image(id, closure)
    }
    
    public func button(_ id: String, _ closure: @escaping (Button) -> Void) {
        AmytisView.button(id, closure)
    }
    
    public func textfield(_ id: String, _ closure: @escaping (TextField) -> Void) {
        AmytisView.textfield(id, closure)
    }
    
    public func tableview(_ id: String, _ closure: @escaping (TableView) -> Void) {
        AmytisView.tableview(id, closure)
    }
    
    public func collectionView(_ id: String, _ closure: @escaping (CollectionView) -> Void) {
        AmytisView.collectionview(id, closure)
    }
    
    public func map(_ id: String, _ closure: @escaping (Map) -> Void) {
        AmytisView.map(id, closure)
    }
    
    public func picker(_ id: String, _ closure: @escaping (Picker) -> Void) {
        AmytisView.picker(id, closure)
    }
    
    public func datepicker(_ id: String, _ closure: @escaping (DatePicker) -> Void) {
        AmytisView.datepicker(id, closure)
    }
    
    public func selection(_ id: String, _ closure: @escaping (Segment) -> Void) {
        AmytisView.selection(id, closure)
    }
    
    public func slider(_ id: String, _ closure: @escaping (Slider) -> Void) {
        AmytisView.slider(id, closure)
    }
    
    public func slideshow(_ id: String, _ closure: @escaping (SlideShow) -> Void) {
        AmytisView.slideshow(id, closure)
    }
    
    public func getSwitch(_ id: String, _ closure: @escaping (Switch) -> Void) {
        AmytisView.getSwitch(id, closure)
    }
}
