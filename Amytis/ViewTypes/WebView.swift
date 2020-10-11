//
//  WebView.swift
//  Alamofire
//
//  Created by Yazdan on 7/18/17.
//
import UIKit
import JavaScriptCore

@objc public protocol WebViewJSExport: JSExport {
    func url(_ url: String) -> WebView
}


public final class WebView: UIWebView, AmytisViewType, WebViewJSExport, UIWebViewDelegate, ExtendableView {
    
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
    
    var _started: (() -> Void)?
    public func startedLoading(action: @escaping (() -> Void)) {
        _started = action
    }
    
    var _finished: (() -> Void)?
    public func finishedLoading(action: @escaping (() -> Void)) {
        _finished = action
    }
    
    convenience init( _ parent: AmytisView, _ rect: Frame, _ object: XML) {
        self.init(frame: CGRect(origin: rect.origin, size: rect.size))
        self.frame2 = rect
        self.parent = parent
        self.viewXML = object
        self.setViewParams(object, parent)
        self.config()
        frame2.rotate = {self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin}
    }

    func empty() {
        frame2.empty()
    }
    
    public func config() {
        viewXML.string(textParams.text, {self.loadHTMLString("<html><body><div dir=\"rtl\">\(UILabel.filteredText($0, self.viewXML))</div></body></html>", baseURL: nil)})
    }
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        _started?()
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        _finished?()
    }
    
    
    //// webview specific functions
    public func url(_ url: String) -> WebView {
        if let ur = URL(string: url) {
            self.loadRequest(URLRequest(url: ur))
        }
        return self
    }
    
    
    
    
}
