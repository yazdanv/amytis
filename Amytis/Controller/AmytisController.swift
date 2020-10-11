//
//  AmytisController.swift
//  Pods
//
//  Created by Yazdan on 5/31/17.
//
//

import UIKit
import JavaScriptCore

var registers = [
    [Button.self, "Button"],
    [CollectionView.self, "CollectionView"],
    [DatePicker.self,"DatePicker"],
    [ImageView.self, "ImageView"],
    [Label.self,"Label"],
    [Map.self,"Map"],
    [Picker.self,"Picker"],
    [Segment.self,"Segment"],
    [Slider.self, "Slider"],
    [SlideShow.self, "SlideShow"],
    [Switch.self, "Switch"],
    [TableView.self, "TableView"],
    [TextField.self, "TextField"],
    [View.self, "View"],
    [WebView.self, "WebView"],
    [RequestHandler.self, "RequestHandler"],
    [ImageManager.self,"ImageManager"],
    [Dyko.self,"Dyko"],
    [DykoFile.self,"DykoFile"],
    [AmytisView.self, "AmytisView"],
    [AmytisController.self, "AmytisController"],
    [SocketConnection.self, "Socket"],
    [RequestHandler.self, "RequestHandler"]
]

@objc public protocol MainAmytisControllerJSExport: JSExport {
    var parameters: [String: Any] { get set }
    func jsOpen(_ name: String, _ params: [String: Any], _ storyBoardName: String)
    func openUrl(_ url: String, _ escape: Bool)
    func pop(_ animated: Bool, _ toRoot: Bool)
    func jsToast(_ message: String, _ completion: JSValue?, _ params: JSValue?)
    func jsChoices(_ dic: JSValue)
    func input(_ dic: JSValue)
    func reRenderTopbar(_ values: [String: String])
    
    
    //// views
    
    func view(_ id: String) -> View?
    func label(_ id: String) -> Label?
    func image(_ id: String) -> ImageView?
    func button(_ id: String) -> Button?
    func textfield(_ id: String) -> TextField?
    func tableview(_ id: String) -> TableView?
    func collectionView(_ id: String) -> CollectionView?
    func map(_ id: String) -> Map?
    func picker(_ id: String) -> Picker?
    func selection(_ id: String) -> Segment?
    func slider(_ id: String) -> Slider?
    func slideshow(_ id: String) -> SlideShow?
    func getSwitch(_ id: String) -> Switch?
    func datepicker(_ id: String) -> DatePicker?
    
}

@objc open class AmytisController: UIViewController, MainAmytisControllerJSExport {
    
    public var aview: AmytisView!
    var context: JSContext!
    public var parameters: [String: Any] = [:]
    var _localActions: [String: (() -> Void)] = [:]
    
    public var pan: Pan {return aview.pan}
    public var swipe: Swipe {return aview.swipe}
    
    open func json(_ url: String, _ parameters: [String: Any] = [:], method: RequestMethod = .get, coding: DataCoding = .json, retry: Int = 1, object: ((JSON) -> Void)? = nil, array: (([JSON]) -> Void)? = nil, failure: (() -> Void)? = nil) {
        RH.json(url, parameters, method: method, coding: coding, retry: retry, object: object, array: array, failure: failure)
    }
    
    var handleCode: [String] = []
    var viewIsLoaded: Bool = false
    
    func initContext() {
        handleCode = []
        viewIsLoaded = false
        context = JSContext()
        context.exceptionHandler = { context, exception in
            if let err = exception {
                dm.log("***ERROR : \(err)")
            }
        }
        for register in registers {
            context.setObject(register[0], forKeyedSubscript: (register[1] as! String) as (NSCopying & NSObjectProtocol)!)
        }
        TimerJS.registerInto(jsContext: context)
        JSLocation.registerInto(jsContext: context)
        locationJSSharedInstance.stop()
    }
    
    public func setArgument(_ name: String, _ object: Any) {
//        if object is (NSCopying & NSObjectProtocol) {
//            if let setView = self.context.objectForKeyedSubscript("set\(name)") {
//                _ = setView.call(withArguments: [object])
//            } else {
                let s = "var \(name.camelCased);function setValueOf\(name.CamelCased)(obj){\(name.camelCased)=obj;}"
                _ = self.context.evaluateScript(s)
                let setView = self.context.objectForKeyedSubscript("setValueOf\(name.CamelCased)")
                _ = setView?.call(withArguments: [object])
//            }
//        }
    }
    
    public func getArgument(_ name: String) -> JSValue? {
        return self.context.objectForKeyedSubscript(name)
    }
    
    func changeArgument(_ name: String, _ object: Any) {
        let setView = self.context.objectForKeyedSubscript("setValueOf\(name.CamelCased)")
        _ = setView?.call(withArguments: [object])
    }
    
    var code: String?
    
    func codeInit(code: XML? = nil, params: [String: Any] = [:]) {
        initContext()
        setArgument("controller", self)
        setArgument("self", self)
        setArgument("obj", self)
        setArgument("request", RH)
        for (key, obj) in params {
            setArgument(key, obj)
        }
        context.evaluateScript(mainJsCode)
        if let code = code {
            let str = code.str
            if str.contains("viewWillLoad") || str.contains("viewLoaded") || str.contains("viewAppeared") {
                _ = self.context.evaluateScript(str)
                _ = context.objectForKeyedSubscript("viewWillLoad")?.call(withArguments: [])
            } else {
                self.code = str
            }
        }
    }
    
    func jsViewLoaded() {
        setArgument("view", aview)
        for (key, obj) in aview.views {
            setArgument(key, obj)
        }
        if let code = self.code {
            _ = self.context.evaluateScript(code.replacingOccurrences(of: "&amp;", with: "&"))
        }
        viewIsLoaded = true
        for item in handleCode {
            self.run(item)
        }
        if code == nil {
            _ = context.objectForKeyedSubscript("viewLoaded")?.call(withArguments: [])
        }
    }
    
    func jsViewAppeared() {
        if code == nil {
            _ = context.objectForKeyedSubscript("viewAppeared")?.call(withArguments: [])
        }
    }
    
    func jsViewDisappered() {
        if code == nil {
            _ = context.objectForKeyedSubscript("viewDisappeared")?.call(withArguments: [])
        }
    }
    
    func hasFunc(_ name: String) -> Bool {
        if context.objectForKeyedSubscript(name) != nil {
            return true
        }
        return false
    }
    
    func runFunc(_ name: String) -> Bool {
        if let f = context.objectForKeyedSubscript(name), !f.isUndefined {
            f.call(withArguments: [])
            return true
        }
        return false
    }
    
    func run(_ code: String) {
        if viewIsLoaded {context.evaluateScript(code)} else {handleCode.append(code)}
    }
    
    public func runJS(_ code: String) {
        if viewIsLoaded {context.evaluateScript(code)} else {handleCode.append(code)}
    }
    
    override open func open(_ name: String, _ parameters: [String: Any] = [:], storyboardName: String = "Main") {super.open(name, parameters, storyboardName: storyboardName)}
    public func jsOpen(_ name: String, _ params: [String: Any], _ storyBoardName: String) {self.open(name, params, storyboardName: storyBoardName)}
    override open func openUrl(_ url: String, _ escape: Bool = false) {super.openUrl(url, escape)}
    override open func pop(_ animated: Bool = true, _ toRoot: Bool = false) {super.pop(animated, toRoot)}
    
    /////// alerted field
    
    public func input(title: String = "", message: String, okBtn: String = "OK".local, cancelBtn: String = "Cancel".local, placeholder: String = "", keyboardType: UIKeyboardType = UIKeyboardType.default, text: String = "", onCharacter: ((UITextField) -> Void)? = nil, cancel: (() -> Void)? = nil, empty: (() -> Void)? = nil, _ action: @escaping ((String) -> Void)) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: okBtn, style: .default, handler: {
            alert -> Void in
            let field = alertController.textFields![0] as UITextField
            if field.text != "" {
                action(field.text!)
            } else {
                empty?()
            }
        }))
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = placeholder
            textField.textAlignment = .center
            textField.keyboardType = keyboardType
            textField.text = text
        })
        alertController.addAction(UIAlertAction(title: cancelBtn, style: .default, handler: {alert in
            cancel?()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func input(_ dic: JSValue) {
        if let message = dic.string("message"), let comp = dic.value("completion") {
            self.input(message: message) {str in comp.call(withArguments: [str])}
        }
    }
    
    public func inputs(title: String = "", message: String = "", okBtn: String = "OK".local, cancelBtn: String = "Cancel".local, placeholders: [String] = [], keyboardTypes: [Int: UIKeyboardType] = [:], texts: [Int: String] = [:], heights: [Int: CGFloat] = [:], params: [String: Any] = ["buttonTextColor": "black"], action: @escaping (([String]) -> Void), _ cancel: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.setValue(title.attributedWithLangFont, forKey: "attributedTitle")
        alertController.setValue(message.attributedWithLangFont(12), forKey: "attributedMessage")
        var fields: [UITextField] = []
        var i = 0;
        for placeholder in placeholders {
            i += 1
            alertController.addTextField(configurationHandler: { (textField) -> Void in
                fields.append(textField)
                textField.placeholder = placeholder
                textField.textAlignment = .center
                textField.text = texts[i]
                textField.font = Amytis.language.langFont()
                if let type = keyboardTypes[i] {
                    textField.keyboardType = type
                }
            })
        }
        let ok = UIAlertAction(title: okBtn.localized, style: .default, handler: {
            alert -> Void in
            var values: [String] = []
            if let flds = alertController.textFields {
                for fld in flds {
                    if let txt = fld.text {
                        values.append(txt)
                    }
                }
            }
            action(values)
        })
        let cancel = UIAlertAction(title: cancelBtn.localized, style: .default, handler: {alert in
            cancel?()
        })
        

        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: {
//            var i2 = 0;
//            var addedHeight: CGFloat = 0
//            for field in fields {
//                i2 += 1
//                if let height = heights[i2] {
//                    alertController.view!.frame.size = CGSize(width: alertController.view!.frame.width, height: alertController.view!.frame.height + (height - field.frame.height) + 5)
//                    addedHeight += (height - field.frame.height) + 5
//                    field.frame.size = CGSize(width: field.frame.width, height: height)
//                } else {
//                    alertController.view!.frame.size = CGSize(width: alertController.view!.frame.width, height: alertController.view!.frame.height + (50 - field.frame.height) + 5)
//                    addedHeight += (50 - field.frame.height) + 5
//                    field.frame.size = CGSize(width: field.frame.width, height: 50)
//                }
//                if i != 1 {field.frame.origin = CGPoint(x: field.frame.origin.x, y: field.frame.origin.y + addedHeight)}
//                field.superview!.frame = field.frame
//            }
        })
    
        let cancelAttributed = cancelBtn.attributedWithLangFont
        let okAttributed = okBtn.attributedWithLangFont
        if let tColor = params["buttonTextColor"] as? String {
            cancelAttributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.pickColor(tColor), range: NSRange(location: 0, length: cancelAttributed.length))
            okAttributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.pickColor(tColor), range: NSRange(location: 0, length: okAttributed.length))
        }
        ((ok.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel)?.attributedText = okAttributed
        ((cancel.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel)?.attributedText = cancelAttributed

        
    }
    
    public func choices(title: String = "", message: String, actions: [String: (() -> Void)], attributes: [String: Any] = [:], dismissable: Bool = true) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.setValue(title.attributedWithLangFont, forKey: "attributedTitle")
        alertController.setValue(message.attributedWithLangFont(12), forKey: "attributedMessage")
        
        var aActions: [UIAlertAction] = []
        
        for key in actions.keys {
            let value = actions[key]!
            let action = UIAlertAction(title: key, style: .default, handler: {alert in
                value()
            })
            aActions.append(action)
            alertController.addAction(action)
        }
        
        self.present(alertController, animated: true, completion: {
            if dismissable {
                let btn = Button()
                btn.frame = alertController.view.superview!.bounds
                alertController.view.superview!.addSubview(btn)
                alertController.view.superview!.bringSubviewToFront(alertController.view)
                btn.clicked {
                    alertController.dismiss(animated: true)
                    btn.removeFromSuperview()
                }
            }
        })
        for item in aActions {
            ((item.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel)?.font = Amytis.language.langFont()
        }
    }
    
    public func jsChoices(_ dic: JSValue) {
        var title = ""
        var message = ""
        var actions: [String: (() -> Void)] = [:]
        if let t = dic.forProperty("title"), !t.isUndefined {title = t.toString()}
        if let m = dic.forProperty("message"), !m.isUndefined  {message = m.toString()}
        if let jacs = dic.forProperty("buttons"), !jacs.isUndefined, let acs = jacs.toArray() as? [String], let comp = dic.forProperty("completion"), !comp.isUndefined {
            var i = 0
            for value in acs {
                i += 1
                let j = i;
                actions[value] = {comp.call(withArguments: [j])}
            }
        }
        self.choices(title: title, message: message, actions: actions)
    }
    
    
    
    public func toast(title: String = "", message: String, time: Double = 2.0, completion: (() -> Void)? = nil) {
        if Amytis.currentToast == nil {
            Amytis.currentToast = UIAlertController(title: title, message: message, preferredStyle: .alert)
            self.present(Amytis.currentToast!, animated: true, completion: nil)
            self.runWD(time) {
                Amytis.currentToast!.dismiss(animated: true, completion: {Amytis.currentToast = nil;completion?()})
            }
            self.runWD(10.0) {Amytis.currentToast = nil}
        } else {
            self.runWD(0.1) {self.toast(title: title, message: message, time: time, completion: completion)}
        }
    }
    
    public func jsToast(_ message: String, _ completion: JSValue?, _ params: JSValue?) {
        var (title, time) = ("", 2.0)
        if let p = params {
            if let t = p.string(jsParams.title) {
                title = t
            }
            if let t = p.double(jsParams.time) {
                time = t
            }
        }
        self.toast(title: title, message: message, time: time, completion: {_ = completion?.call(withArguments: [])})
    }
    
    
    ///// binders to aview
    
    public func bindToPan(view: UIView, end: CGPoint = CGPoint.zero, direction: BindPanDirection = .x, incremental: Bool = false, ended: (() -> Void)? = nil) {
        aview.bindToPan(view: view, end: end, direction: direction, incremental: incremental, ended: ended)
    }

    /////// topBar Config
    
    public var topView: AmytisView?
    
    func configTopBar(_ object: XML) {
        var nav: UINavigationController?
        var navI: UINavigationItem?
        if let navi = self.tabBarController?.navigationController {nav = navi; navI = self.tabBarController!.navigationItem} else if let navi = self.navigationController {nav = navi; navI = self.navigationItem}
        if let nav = nav, let navI = navI {
            var titleColor = UIColor.white
            var titleSize: CGFloat = 14
            object.string(textParams.titleColor) {titleColor = UIColor.pickColor($0)}
            object.double(textParams.titleSize) {titleSize = CGFloat($0)}
            var hiddenChanged = false;
            object.bool(viewParams.hidden, {nav.isNavigationBarHidden = $0; hiddenChanged = true})
            if !hiddenChanged {nav.isNavigationBarHidden = false}
            if let font = Amytis.language.langFont(size: titleSize) {
                nav.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: font, NSAttributedString.Key.foregroundColor.rawValue: titleColor])
            } else {
                nav.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: titleColor])
            }
            object.string(topParams.topBarVals.title) {self.title = $0}
            object.string(viewParams.backgroundColor) {nav.navigationBar.setBackgroundImage(nil, for: .default); nav.navigationBar.barTintColor = UIColor.pickColor($0)}
            object.string(viewParams.background) {
                nav.navigationBar.setBackgroundImage(Image.load(named: $0).resizableImage(withCapInsets: UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0), resizingMode: .stretch), for: .default)
            }
            var had = false
            func calculate(_ xml: XML) {
                var width: CGFloat = 200
                xml.int(viewParams.width) {width=CGFloat($0)}
                xml.string(viewParams.frame) {frm in
                    let window = UIApplication.shared.keyWindow!.frame
                    if frm == "full" {
                        width = window.width
                    } else {
                        if let s = Frame.calculate(Frame.replaceRect(frm, CGRect.zero, CGRect(x: 0, y: 0, width: window.width, height: 40))) {width = CGFloat(s)}
                    }
                }
                let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 40))
                navI.titleView = view
                topView = view.createAmytisView(viewDidLoad: {
                    for (key, val) in self.topView!.views {
                        self.setArgument(key, val)
                    }
                }, controller: self)
            }
            object.xml(["views", "view"]) {xml in
                had = true
                calculate(xml)
                topView?.populateWith(xmlD: xml)
            }
            if !had, object.children.count > 0 {
                calculate(object)
                topView?.populateWith(xmlArr: object.children)
            }
        }
    }
    
    public func reRenderTopbar(_ values: [String: String]) {
        if let top = dm.get(amytisControllerName, paramsJ: parameters, topBar: true) {
            for (key, value) in values {
                top.attributes[key] = value
            }
            self.configTopBar(top)
        }
    }
    

    ///////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////// binding to uiviewcontroller/////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    public var loaded: Bool = false
    public var amytisControllerName: String = "name"
    
    var onDisappearActions: [(() -> Void)] = []
    public func onDisappearAction(_ action: @escaping (() -> Void)) {
        onDisappearActions.append(action)
    }
    
    var onAppearActions: [(() -> Void)] = []
    public func onAppearAction(_ action: @escaping (() -> Void)) {
        onAppearActions.append(action)
    }
    
    var lastHeight: CGFloat = 0.0
    var lastWidth: CGFloat = 0.0
    
    func initName() {
        if let id = self.restorationIdentifier {
            amytisControllerName = id
        } else if let nm = parameters["amytisControllerName"] as? String {
            amytisControllerName = nm
        }
        dm.loadIfNotExist(amytisControllerName)
        dm.AmytisViews[amytisControllerName] = self
        dm.currentController = self
        aview = view.createAmytisView(viewDidLoad: {
            self.viewLoaded()
            self.jsViewLoaded()
            if self.loaded {self.viewAppeared();self.jsViewAppeared()}
            self.loaded=true
        }, controller: self)
        dm.currentView = aview
    }
    
    override open func viewDidLoad() {
//        if (Amytis.DEBUG) {
//            print("\n\nView \(amytisControllerName) Loaded\n\n")
//        }
        initName()
        super.viewDidLoad()
        __config()
    }
    
    func __config() {
        lastHeight = self.view.frame.height
        lastWidth = self.view.frame.width
        viewWillLoad()
        codeInit(code: dm.codes[amytisControllerName], params: self.parameters)
        startLoadingViews()
    }
    
    func __dmReloadDebugViews() {
        __config()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.view.frame.height != lastHeight || self.view.frame.width != lastWidth {
            lastHeight = self.view.frame.height
            if aview != nil {
                self.aview.reCalculateSizes()
            }
        }
    }
    
//    open override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if self.view.frame.height != lastHeight {
//            lastHeight = self.view.frame.height
//            if aview != nil {
//                self.aview.reCalculateSizes()
//            } else {
//                self.startLoadingViews()
//            }
//        }
//    }
    
    func startLoadingViews() {
        if let top = dm.get(amytisControllerName, paramsJ: parameters, topBar: true) {self.configTopBar(top)}
        aview.populateWith(name: amytisControllerName, paramsJ: parameters)
    }
    
    public func reloadAll() {
        startLoadingViews()
    }
    
    public func reloadTop() {
        if let top = dm.get(amytisControllerName, paramsJ: parameters, topBar: true) {
            self.configTopBar(top)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if loaded {
            self.viewAppeared()
            self.jsViewAppeared()
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        if let top = dm.get(amytisControllerName, paramsJ: parameters, topBar: true) {
            self.configTopBar(top)
        }
        super.viewWillAppear(animated)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.jsViewDisappered()
        for action in onDisappearActions {
            action()
        }
    }
    
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.toast(message: languageKeys.didGetMemoryWarning.local) {
            self.pop()
        }
    }
    
    open func viewWillLoad() {
        
    }
    
    open func viewLoaded() {
        
    }
    
    open func viewAppeared() {
        
    }
    
    
    //////////////////////////////////////////////////
    //////// aview View extract methods helper////////
    /////////////////////////////////////////////////
    
    open func view(_ id: String) -> View? {
        return aview.view(id)
    }
    
    open func label(_ id: String) -> Label? {
        return aview.label(id)
    }
    
    open func image(_ id: String) -> ImageView? {
        return aview.image(id)
    }
    
    open func button(_ id: String) -> Button? {
        return aview.button(id)
    }
    
    open func textfield(_ id: String) -> TextField? {
        return aview.textfield(id)
    }
    
    open func tableview(_ id: String) -> TableView? {
        return aview.tableview(id)
    }
    
    open func collectionView(_ id: String) -> CollectionView? {
        return aview.collectionview(id)
    }
    
    open func map(_ id: String) -> Map? {
        return aview.map(id)
    }
    
    open func picker(_ id: String) -> Picker? {
        return aview.picker(id)
    }
    
    open func selection(_ id: String) -> Segment? {
        return aview.selection(id)
    }
    
    open func slider(_ id: String) -> Slider? {
        return aview.slider(id)
    }
    
    open func slideshow(_ id: String) -> SlideShow? {
        return aview.slideshow(id)
    }
    
    open func getSwitch(_ id: String) -> Switch? {
        return aview.getSwitch(id)
    }
    
    open func datepicker(_ id: String) -> DatePicker? {
        return aview.datepicker(id)
    }
    
    ///////// using views by closure
    
    open func view(_ id: String, _ closure: @escaping (View) -> Void) {
        aview.view(id, closure)
    }
    
    open func label(_ id: String, _ closure: @escaping (Label) -> Void) {
        aview.label(id, closure)
    }
    
    open func image(_ id: String, _ closure: @escaping (ImageView) -> Void) {
        aview.image(id, closure)
    }
    
    open func button(_ id: String, _ closure: @escaping (Button) -> Void) {
        aview.button(id, closure)
    }
    
    open func textfield(_ id: String, _ closure: @escaping (TextField) -> Void) {
        aview.textfield(id, closure)
    }
    
    open func tableview(_ id: String, _ closure: @escaping (TableView) -> Void) {
        aview.tableview(id, closure)
    }
    
    open func collectionView(_ id: String, _ closure: @escaping (CollectionView) -> Void) {
        aview.collectionview(id, closure)
    }
    
    open func map(_ id: String, _ closure: @escaping (Map) -> Void) {
        aview.map(id, closure)
    }
    
    open func picker(_ id: String, _ closure: @escaping (Picker) -> Void) {
        aview.picker(id, closure)
    }
    
    open func selection(_ id: String, _ closure: @escaping (Segment) -> Void) {
        aview.selection(id, closure)
    }
    
    open func slider(_ id: String, _ closure: @escaping (Slider) -> Void) {
        aview.slider(id, closure)
    }
    
    open func slideshow(_ id: String, _ closure: @escaping (SlideShow) -> Void) {
        aview.slideshow(id, closure)
    }
    
    open func getSwitch(_ id: String, _ closure: @escaping (Switch) -> Void) {
        aview.getSwitch(id, closure)
    }
    
    open func datepicker(_ id: String, _ closure: @escaping (DatePicker) -> Void) {
        aview.datepicker(id, closure)
    }
    
    
}



///////////////////////// UIViewController Extension

extension UIViewController {
    @objc open func open(_ name: String, _ parameters: [String: Any] = [:], storyboardName: String = "Main") {
        runAsync {
            var params = parameters
            params["amytisControllerName"] = name
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            let exists = (storyboard.value(forKey: "identifierToNibNameMap") as? NSDictionary)?.value(forKey: name)
            if exists != nil, let controller = storyboard.instantiateViewController(withIdentifier: name) as? AmytisController {
                controller.parameters = params
                self.navigationController?.pushViewController(controller, animated: true)
            } else if exists != nil {
                let controller = storyboard.instantiateViewController(withIdentifier: name)
                self.navigationController?.pushViewController(controller, animated: true)
            } else if dm.get(name, paramsJ: parameters) != nil {
                if self.navigationController != nil {
                    let controller = AmytisController()
                    controller.parameters = params
                    controller.restorationIdentifier = name
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    
                }
            }
        }
    }
    
    @objc open func pop(_ animated: Bool = true, _ toRoot: Bool = false) {
        if let nav = navigationController {
            if toRoot {nav.popToRootViewController(animated: animated)} else {nav.popViewController(animated: animated)}
        } else {
            self.dismiss(animated: animated, completion: nil)
        }
    }
    
    @objc open func openUrl(_ url: String, _ escape: Bool = false) {
        var __url = url
        if escape {
            let mapping = [
                ("\\", "\\\\"),
                ("'", "\\'"),
                ("\n", "\\n"),
                ("\r", "\\r"),
                ("\u{2028}", "\\u2028"),
                ("\u{2029}", "\\u2029")
            ]
            for (src, dst) in mapping {
                __url = __url.replacingOccurrences(of: src, with: dst, options: .literal)
            }
            let script = "var value = encodeURI('\(__url)');"
            let context: JSContext! = JSContext()
            context.evaluateScript(script)
            let value: JSValue = context.objectForKeyedSubscript("value")
            __url = value.toString()
        }
        if let _url = URL(string: __url) {UIApplication.shared.openURL(_url)}
    }    

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
