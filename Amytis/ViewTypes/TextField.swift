//
//  TextField.swift
//  Pods
//
//  Created by Yazdan on 3/22/17.
//
//


import UIKit
import JavaScriptCore

@objc public protocol TextFieldJSExport: JSExport {
    var text: String? {get set}
    var txt: String {get set}
    func getText() -> String
    func event(_ state: String, _ completion: JSValue)
    func text(_ string: String) -> TextField
    func placeholder(_ string: String) -> TextField
    func textColor(_ string: String) -> TextField
    func font(_ string: String) -> TextField
}

public final class TextField: UITextField, AmytisViewType, TextFieldJSExport, ExtendableView {
    
    
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
    public func requiredInit() {}
    @objc public func reRenderWithChild(_ xml: String) {_reRender(xml)}
    @objc public func reRender(_ params: [String: Any]) {_reRender(params)}
    @objc public func reCalculateFrame(_ animated: Bool) {_reCalculateFrame(animated)}
    @objc public func animateToFrame(_ string: String, _ time: Double = 0.5, _ completion: JSValue? = nil) {
        _ = animateToFrame(string, time, {_ = completion?.call(withArguments: [])})
    }
    ///////////////////////////////////////////////
    public func text(_ string: String) -> TextField {
        viewXML.attributes[textParams.text[0]] = string
        configTitle()
        return self
    }
    public func placeholder(_ string: String) -> TextField {
        viewXML.attributes[textParams.placeholder[0]] = string
        configTitle()
        return self
    }
    public func textColor(_ string: String) -> TextField {
        viewXML.attributes[textParams.textColor[0]] = string
        configTitle()
        return self
    }
    public func font(_ string: String) -> TextField {
        viewXML.attributes[textParams.font[0]] = string
        configTitle()
        return self
    }
    public var txt: String {
        get {return getText()}
        set {text = txt}
    }
    public func getText() -> String {
        if text != nil {return text!} else {return ""}
    }
    ///////////////////////////////////////////////
    
    var actions: [Int: (() -> Void)] = [:]
    
    var maxCharacters: Int?
    
    convenience init(_ parent: AmytisView, _ rect: Frame, _ object: XML) {
        self.init(frame: CGRect(origin: rect.origin, size: rect.size))
        self.frame2 = rect
        self.parent = parent
        self.viewXML = object
        self.setViewParams(object, parent)
        self.config()
        frame2.rotate = {self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin}
        for ext in Amytis.textfieldExtensions {ext(self)}
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }
    
    deinit {
        frame2.empty()
    }
    
    func empty() {
        frame2.empty()
    }
    
    public func config() {
        viewXML.string(textParams.inputType, {type in
            if (type.compare(textParams.inputTypes.number)) {
                runAsync {
                    self.keyboardType = .numberPad
                }
            }
        })
        runAsync {self.borderStyle = .roundedRect}
        viewXML.string(textParams.borderStyle, {bs in
            if bs.compare(textParams.borderStyles.none) {
                runAsync {self.borderStyle = .none}
            } else if bs.compare(textParams.borderStyles.line) {
                runAsync {self.borderStyle = .line}
            } else if bs.compare(textParams.borderStyles.bezel) {
                runAsync {self.borderStyle = .bezel}
            } else if bs.compare(textParams.borderStyles.round) {
                runAsync {self.borderStyle = .roundedRect}
            }
        })
        viewXML.int(textParams.maxCharacters) {
            self.maxCharacters = $0
            self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        }
        configTitle()
        configImage()
    }
    
    func configTitle() {
        viewXML.string(textParams.textColor, { (colorName: String) in
            self.runAsync {self.textColor = UIColor.pickColor(colorName)}
        })
        if viewXML.string != "" {
            self.runAsync {self.placeholder = UILabel.filteredText(self.viewXML.str, self.viewXML)}
        } else {
            viewXML.string(textParams.placeholder, { (placeholder: String) in
                self.runAsync {
                    self.placeholder = UILabel.filteredText(placeholder, self.viewXML)
                    self.viewXML.string(textParams.placeholderColor, {colorName in
                        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.pickColor(colorName)]))
                    })
                }
            })
        }
        viewXML.bool(textParams.secure) {s in
            self.isSecureTextEntry = s
        }
        viewXML.string(textParams.text, { (text: String) in
            self.runAsync {self.text = UILabel.filteredText(text, self.viewXML)}
        })
        self.runAsync {self.textAlignment = UILabel.alignment(self.viewXML)}
        self.runAsync {self.font = UILabel.font(self.font, self.viewXML)}
        self.runAsync {self.font = UILabel.textSize(self.font, self.viewXML)}

    }
    
    func configImage() {
        viewXML.string(imageParams.source, { (source: String) in
            if source.contains("http") {
                self.loadFromUrl(source)
            } else if source.contains("local:") {
                if let image = UIImage(named: source.replacingOccurrences(of: "local:", with: "")) {
                    self.background = image
                }
            } else if source.contains("online:") {
                
            }
        })
    }
    
    func loadFromUrl(_ string: String) {
        var loading: UIActivityIndicatorView? = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame2.size))
        loading!.color = .black
        //loading!.backgroundColor = .
        self.runAsync {self.addSubview(loading!)}
        loading!.startAnimating()
        loadImage(string, {(image: UIImage) in
            self.background = image
            loading!.stopAnimating()
            loading!.removeFromSuperview()
            loading = nil
        })
    }
    
    func loadImage(_ string: String, _ setImage: @escaping ((UIImage) -> Void)) {
        if let url = URL(string: string) {
            URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    self.runAsync { () -> Void in
                        setImage(image)
                    }
                }
                }.resume()
        }
    }
    
    public func event(_ state: String, _ completion: JSValue) {
        if (state.compare(textParams.controlEvents.editingDidBegin)) {
            action(UIControl.Event.editingDidBegin, {completion.call(withArguments: [])})
        } else if (state.compare(textParams.controlEvents.editingDidEnd)) {
            action(UIControl.Event.editingDidEnd, {completion.call(withArguments: [])})
        } else if (state.compare(textParams.controlEvents.editingChanged)) {
            action(UIControl.Event.editingChanged, {completion.call(withArguments: [])})
        } else if (state.compare(textParams.controlEvents.editingDidEndOnExit)) {
            action(UIControl.Event.editingDidEndOnExit, {completion.call(withArguments: [])})
        }
    }
    
    public func action(_ state: UIControl.Event, _ action: @escaping (() -> Void)) {
        switch state {
            case UIControl.Event.editingDidBegin:
                self.addTarget(self, action: #selector(editingDidBegin), for: state)
                self.actions[1] = action
            case UIControl.Event.editingDidEnd:
                self.addTarget(self, action: #selector(editingDidEnd), for: state)
                self.actions[2] = action
            case UIControl.Event.editingChanged:
                self.addTarget(self, action: #selector(editingChanged), for: state)
                self.actions[3] = action
            case UIControl.Event.editingDidEndOnExit:
                self.addTarget(self, action: #selector(editingDidEndOnExit), for: state)
                self.actions[4] = action
            default:
                break;
        }
        
    }
    
    @objc func editingDidBegin(sender: UITextField) {
        self.actions[1]?()
    }
    @objc func editingDidEnd(sender: UITextField) {
        self.actions[2]?()
    }
    @objc func editingChanged(sender: UITextField) {
        if let max = maxCharacters, let text = text {
            if text.count > max {
                self.text!.removeLast()
            }
        }
        self.actions[3]?()
    }
    @objc func editingDidEndOnExit(sender: UITextField) {
        self.actions[4]?()
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
