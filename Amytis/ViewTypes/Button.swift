//
//  Button.swift
//  Pods
//
//  Created by Yazdan on 3/22/17.
//
//


import UIKit
import JavaScriptCore

@objc public protocol ButtonJSExport: JSExport {
    func text(_ string: String) -> Button
    func textColor(_ string: String) -> Button
    func font(_ string: String) -> Button
    func onClick(_ action: JSValue)
    func setSource(_ source: String)
}

public final class Button: UIButton, AmytisViewType, ButtonJSExport, ExtendableView {
    
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
    public func text(_ string: String) -> Button {
        viewXML.attributes[textParams.text[0]] = string
        configTitle()
        return self
    }
    public func textColor(_ string: String) -> Button {
        viewXML.attributes[textParams.textColor[0]] = string
        configTitle()
        return self
    }
    public func font(_ string: String) -> Button {
        viewXML.attributes[textParams.font[0]] = string
        configTitle()
        return self
    }
    ///////////////////////////////////////////////
    
    public var aview: AmytisView {
        return parent.parent
    }
    public var clicked: (() -> Void)?
    
    public func clicked(_ action: @escaping (() -> Void)) {
        self.clicked = action
    }

    public func onClick(_ action: JSValue) {
        self.clicked = {action.call(withArguments: [])}
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
    }
    
    convenience init(_ parent: AmytisView, _ rect: Frame, _ object: XML) {
        self.init(frame: CGRect(origin: rect.origin, size: rect.size))
        self.parent = parent
        self.viewXML = object
        self.setViewParams(object, parent)
        self.config()
        self.frame2 = rect
        frame2.rotate = {
            self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin
        }
        for ext in Amytis.buttonExtensions {ext(self)}
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        _frame = nil
    }
    
    func empty() {
        if _frame != nil {
            _frame.empty()
            _frame = nil
        }
    }
    
    public func config() {
        configTitle()
        /// figure out what to do when clicked
//        let clickOptions = {(job: String, valS: String, valJ: XML?, params: XML?, param: String?) in
//            if (job.compare(ap.clickedTypes.open)) {
//                if  valJ != nil {
//                    self.clicked = {self.parent.parent.populateWithAnimation(xmlD: valJ)}
//                }
//                if valS != "" {
//                    self.clicked = {
//                        self.parent.parent.populateWithAnimation(name: valS, paramsS: param, paramsX: self.viewXML)
//                    }
//                }
//            } else if (job.compare(ap.clickedTypes.back)) {
//                if self.parent.parent.viewsTrack.count < 2 {
//                    self.isHidden = true
//                }
//                self.clicked = {
//                    self.parent.parent.viewsTrack.removeLast()
//                    if let obj = self.parent.parent.viewsTrack.last {
//                        self.parent.parent.populateWithAnimation(name: obj.name, paramsS: obj.paramS, paramsX: obj.paramX, paramsX2: obj.paramX2, paramsJ: obj.paramJ)
//                    }
//                }
//            }
//        }
//
//        self.viewXML.xml(ap.clicked, { (clicked: XML) in
//            clicked.string(actionParams.job, { (job: String) in
//                var valJ: XML?
//                var valS: String = ""
//                clicked.string(actionParams.value, { (value: String) in
//                    valS = value
//                })
//                clicked.xml(actionParams.value, { (value: XML) in
//                    valJ = value
//                })
//                clickOptions(job, valS, valJ, clicked, nil)
//            })
//
//        })
//        let configClick: ((String) -> Void) = {clicked in
//            let sides = clicked.components(separatedBy: cp.partsDivider)
//            let use = {(val: String, params: String?) in
//                let comps = val.components(separatedBy: cp.valueDivider)
//                if comps.count > 1{
//                    clickOptions(comps[0], comps[1], nil, nil, params)
//                } else {
//                    clickOptions(comps[0], "", nil, nil, params)
//                }
//            }
//            if sides.count > 1 {
//                use(sides[0], sides[1])
//            } else {
//                self.clicked = {
//                    self.parent.controller.run(clicked)
//                }
//            }
//        }
        if viewXML.string != "" {
            self.clicked = {
                if (!self.parent.controller.runFunc(self.viewXML.str)) {
                    self.parent.controller.changeArgument("obj", self)
                    self.parent.controller.run(self.viewXML.str)
                }
            }
        } else {
            self.viewXML.string(ap.clicked, {clicked in
                self.clicked = {
                    if (!self.parent.controller.runFunc(clicked)) {
                        self.parent.controller.changeArgument("obj", self)
                        self.parent.controller.run(clicked)
                    }
                }
            })
        }

        configImage()
    }
    
    func configTitle() {
        self.setTitleColor(.black, for: .normal)
        viewXML.string(textParams.textColor, {self.setTitleColor(UIColor.pickColor($0), for: .normal)})
        viewXML.string(textParams.text, {self.setTitle(UILabel.filteredText($0, self.viewXML), for: .normal)})
        if let title = self.titleLabel {
            title.textAlignment = UILabel.alignment(self.viewXML)
            title.numberOfLines = UILabel.lines(self.viewXML)
            title.font = UILabel.font(title.font, self.viewXML)
            title.font = UILabel.textSize(title.font, self.viewXML)
        }
    }
    
    func configImage() {
        viewXML.string(imageParams.source, {self.setSource($0)})
    }
    
    public func setSource(_ source: String) {
        if source.contains("http") {
            self.setImage(Image.load(url: source, {img in
                self.setImage(img, for: .normal)
            }), for: .normal)
        } else {
            if let image = UIImage(named: source.replacingOccurrences(of: "local:", with: "")) {
                self.setImage(image, for: .normal)
            } else if let image = Image.load(source.replacingOccurrences(of: "local:", with: "")) {
                self.setImage(image, for: .normal)
            }
        }
    }
    
    @objc func btnClicked() {
        self.clicked?()
    }
    
    var _touchDown: (() -> Void)?
    var _touchDownRepeat: (() -> Void)?
    var _touchDragEnter: (() -> Void)?
    var _touchUpOutside: (() -> Void)?
    var _primaryActionTriggered: (() -> Void)?
    
    public func action(_ event: UIControl.Event, _ action: @escaping (() -> Void)) {
        switch (event) {
            case .touchDown:
                self.addTarget(self, action: #selector(touchDown), for: event)
                _touchDown = action
            case .touchDownRepeat:
                self.addTarget(self, action: #selector(touchDownRepeat), for: event)
                _touchDownRepeat = action
            case .touchUpOutside:
                self.addTarget(self, action: #selector(touchUpOutside), for: event)
                _touchUpOutside = action
            case .primaryActionTriggered:
                self.addTarget(self, action: #selector(primaryActionTriggered), for: event)
                _primaryActionTriggered = action
            default:
                break;
        }
    }
    
    @objc func touchDown() {
        _touchDown?()
    }
    
    @objc func touchDownRepeat() {
        _touchDownRepeat?()
    }
    
    func touchDragEnter() {
        _touchDragEnter?()
    }
    
    @objc func touchUpOutside() {
        _touchUpOutside?()
    }
    
    @objc func primaryActionTriggered() {
        _primaryActionTriggered?()
    }
    
}

