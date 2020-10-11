//
//  AmytisView.swift
//  AmytisViews
//
//  Created by Yazdan on 3/16/17.
//  Copyright © 2017 Yazdan. All rights reserved.
//

import UIKit

//MARK: XML Object Class
class xmlObj: NSObject {
    var name: String!
    var paramS: String?
    var paramX: XML?
    var paramX2: XML?
    var paramJ: [String: Any]?
    init(_ name: String, _ paramsS: String? = nil, _ paramsX: XML? = nil, _ paramsX2: XML? = nil, _ paramsJ: [String: Any]? = nil) {
        self.name = name
        self.paramS = paramsS
        self.paramX = paramsX
        self.paramX2 = paramsX2
        self.paramJ = paramsJ
    }
}


//MARK: Variables to store and initial config
public class AmytisView: NSObject, AmytisViewJSExport {
    
    public var view: UIView!
    var _controller: AmytisController?
    public var controller: AmytisController {
        return parent._controller!
    }
    var prnt: AmytisView?
    public var parent: AmytisView {
        if let prnt = prnt {
            return prnt.parent
        } else {
            return self
        }
    }
    var parentView: UIView?
    var topBarView: UIView?
    var topBar: AmytisView?
    var viewDidLoad: (() -> Void)?
    var loaded = false
    func _hasTop() {
        if controller.navigationController != nil, UIApplication.shared.keyWindow!.frame.height == view.frame.height {
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + 64, width: view.frame.width, height: view.frame.height - 64)
        }
    }
    
    var viewXML: XML?
    
    var viewsTrack: [xmlObj] = []
    
    var firstRecord: Double!
    var reload: (() -> Void)?
    var codeDone = true
    public var gestureRecognizers: [UISwipeGestureRecognizer] = []
    public var swipe = Swipe()
    public var pan = Pan()
    
    init(_ view: UIView, _ viewDidLoad: (() -> Void)? = nil, _ controller: AmytisController? = nil, parent: AmytisView? = nil) {
        super.init()
        self.view = view
        self.prnt = parent
        // configure swipe
        if let c = controller {
            self._controller = c
            self.prnt = nil
        }
        self.viewDidLoad = viewDidLoad
    }
    
    
    public func open(_ name: String, _ params: [String: Any]?) {
        if let params = params {
            controller.open(name, params)
        } else {
            controller.open(name)
        }
    }
    
    /** 
     This function would get a json 'String' or 'Data' and would populate the origin view with the given json
     **Warning:** This function would clear the origin view from any subviews
     
     Usage:
        let AmytisView = view.createAmytisView()
        AmytisView.populateWith(string: "{"views": [{"type": "image", "id": "top-right-image", "pos": "TR","size": "150x150", "source": "https://i.ytimg.com/vi/m5d1FlSeF-M/maxresdefault.jpg"}]}")
     
     :param: data to capture Json from Data
     :param: string to capture Json from String
     
    */
    public func populateWith(name: String? = nil, paramsS: String? = nil, paramsX: XML? = nil, paramsX2: XML? = nil, paramsJ: [String: Any]? = nil, data: Data? = nil, string: String? = nil, file: String? = nil, xmlD: XML? = nil, xmlArr: [XML]? = nil, animated: Bool = false, execCode: Bool = false, parent: AmytisView? = nil, logs shouldLog: Bool = false) {
            _ = Amytis.on
        self.populatewt(name: name, paramsS: paramsS, paramsX: paramsX, paramsX2: paramsX2, paramsJ: paramsJ, data: data, string: string, file: file, xmlD: xmlD, xmlArr: xmlArr, animated: animated, execCode: execCode, parent: parent, logs: shouldLog)
    }
    
    public func populatewt(name: String? = nil, paramsS: String? = nil, paramsX: XML? = nil, paramsX2: XML? = nil, paramsJ: [String: Any]? = nil, data: Data? = nil, string: String? = nil, file: String? = nil, xmlD: XML? = nil, xmlArr: [XML]? = nil, animated: Bool = false, execCode: Bool = false, parent: AmytisView? = nil, logs shouldLog: Bool = false) {
        firstRecord = currentTimeMillis()
        var xml: XML?
        if let name = name {
            
            if let last = viewsTrack.last {
                if last.name != name {
                viewsTrack.append(xmlObj(name, paramsS, paramsX, paramsX2, paramsJ))
                }
            } else {
                viewsTrack.append(xmlObj(name, paramsS, paramsX, paramsX2, paramsJ))
            }
            xml = dm.get(name, paramsS: paramsS, paramsX: paramsX, paramsXAttr: paramsX2, paramsJ: paramsJ)
        } else if let file = file, let path = Bundle.main.path(forResource: file, ofType: "xml"), let data = NSData(contentsOfFile: path) {
            do {xml = try XMLDocument(xml: data as Data)} catch {}
        } else if let string = string, let data = string.data(using: String.Encoding.utf8) {
            do {xml = try XMLDocument(xml: data)} catch {}
        } else if let data = data {
            do {xml = try XMLDocument(xml: data)} catch {}
        } else if let xmlD = xmlD {
            xml = xmlD
        }
        
        
        if (xml == nil && xmlArr == nil) {
            self.viewDidLoad?()
            return
        }
    
            
        //detect if the xml is for a simple view or specific ones//
        
        func replacingChildren(_ xmls: [XML]) -> ([XML], XML?) {
            var xmlsFinal: [XML] = []
            var top: XML?
            for xml in xmls {
                let (key, xml2) = detectInclude(xml: xml)
                if key.compare(topParams.topBar) {
                   top = xml2
                }else {
                    xmlsFinal.append(xml2)
                }
            }
            return (xmlsFinal, top)
        }
        var top: XML?
        
        allViewsLoaded = {
            self.loaded = true
            for view in self.tmpViews {self.view.addSubview(view)}
            if self.prnt != nil {
                for (key, val) in self.views {
                    self.prnt!.views[key] = val
                }
            }
            self.tmpViews = []
            self.viewDidLoad?()
        }
        
        self.clear()
        
        ///////////////////////////
        var xmls: [XML] = []
        
        if let xml = xml {
            self.viewXML = xml
            let xmlDoc = xml[tp.views[0]]
            if xmlDoc.error != AEXMLError.elementNotFound  {
                (xmls, top) = replacingChildren(xmlDoc.children)
                view.setViewParams(xmlDoc, self, padding: true, main: true)
                plainView(parent: view, views: xmls)
            } else if xml.name == "views" {
                (xmls, top) = replacingChildren(xml.children)
                view.setViewParams(xml, self, padding: true, main: true)
                plainView(parent: view, views: xmls)
            } 
        } else if let views = xmlArr {
            var views2: [XML] = []
            (views2, top) = replacingChildren(views)
            plainView(parent: view, views: views2)
        }
        allViewsLoaded()
        
        xml?.yes(["screenShot"]) {dm.sendScreen()}
        
        if shouldLog {print("time elapsed:   \(currentTimeMillis() - firstRecord) ms")}
    }
    
    var allViewsLoaded: (() -> Void)!
    
    func viewLoaded() {
        viewsLoaded += 1
        if viewsLoaded >= totalViews {
            if !self.loaded {
                allViewsLoaded()
            }
        }
    }
    
    let reCalculateAnimateTime = 0.2
    
    public func reCalculateSizes(_ animated: Bool = false) {
        for v in viewsStore {
            if let view = v as? View {
                let frame = Frame.create(from: view.viewXML, withParent: self.view, Aview: self)
                view.frame2 = frame
                if view.AmytisView != nil {
                    view.frame = frame.rect
                    view.setViewParams(view.viewXML, self)
                    view.AmytisView.reCalculateSizes(animated)
                } else if animated {
                    UIView.animate(withDuration: reCalculateAnimateTime, animations: {
                        view.frame = frame.rect
                        view.setViewParams(view.viewXML, self)
                    })
                } else {
                    view.frame = frame.rect
                    view.setViewParams(view.viewXML, self)
                }
            } else {
                v.reCalculateFrame(animated)
            }
        }
        if let bg = image("theBackgroundOfView") {
            bg.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.frame.size)
        }
    }
    
    //MARK: populating the view and present it on the old view with animation
    public func populateWithAnimation(name: String? = nil, paramsS: String? = nil, paramsX: XML? = nil, paramsX2: XML? = nil, paramsJ: [String: Any]? = nil, data: Data? = nil, string: String? = nil, file: String? = nil, xmlD: XML? = nil, animated: Bool = false, parent: AmytisView? = nil, logs shouldLog: Bool = false) {
        var par: UIView = self.view
        if let prntV = parentView {
            par = prntV
        }
        if let sup = par.window {
        let vw = UIView(frame: CGRect(x: par.frame.size.width, y: par.frame.origin.y, width: par.frame.size.width, height: par.frame.size.height))
            sup.addSubview(vw)
            let jsnView = vw.createAmytisView()
            jsnView.populateWith(name: name, paramsS: paramsS, paramsX: paramsX, paramsX2: paramsX2, paramsJ: paramsJ, data: data, string: string, file: file, xmlD: xmlD, animated: false, parent: parent, logs: shouldLog)
            UIView.animate(withDuration: 0.3, animations: {
                vw.frame.origin = CGPoint(x: par.frame.origin.x, y: par.frame.origin.y)
            }, completion: {(comp: Bool) in
                self.populateWith(name: name, paramsS: paramsS, paramsX: paramsX, paramsX2: paramsX2, paramsJ: paramsJ, data: data, string: string, file: file, xmlD: xmlD, animated: true, execCode: true, parent: parent, logs: shouldLog)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                    vw.removeFromSuperview()
                    jsnView.clear()
                })
            })
        }
    }
    
    
    //MARK: detecting and configin the topbar for each view
    func configTopBar(_ item: XML?) {
        if let item = item {
            let topConfig = {(tp: String) in
                do {
                    let top = try XMLDocument(xml: tp).root
                    var bk = "back"
                    if let back = top.attributes["back"] {
                        bk = back
                    }
                    if self.viewsTrack.count > 1, bk != "custom" {
                        let xml = try XMLDocument(xml: "<button tc=\"blue\" text=\"\(bk)\" frame=\"1/6*1.1--1/2*1.75\" clicked=\"back\"/>").root
                        top.addChild(xml)
                    }
                    if self.topBar == nil {
                        self.parentView = self.view
                        self.view = UIView(frame: CGRect(x: 0, y: 64 , width: self.parentView!.frame.size.width, height: self.parentView!.frame.size.height - 64))
                        let topView = UIView(frame: CGRect(x: 0, y: 0 , width: self.parentView!.frame.size.width, height: 64))
                        self.parentView?.addSubview(self.view)
                        self.parentView?.addSubview(topView)
                        
                        self.topBar = topView.createAmytisView()
                        self.topBar?.populateWith(xmlArr: top.children, parent: self)
                        
                    } else {
                        self.topBar?.populateWith(xmlArr: top.children, parent: self)
                    }
                    self.topBar?.view.setViewParams(top, self.topBar!)
                } catch {}
            }
            
            if item.str != "" {
                var js: String = ""
                var params = ""
                var tp = item.str
                if tp.contains(cp.partsDivider) {
                    tp = item.str.components(separatedBy: cp.partsDivider)[0]
                    params = item.str.components(separatedBy: cp.partsDivider)[1]
                }
                if tp.compare(topParams.topBarTypes.simple) {
//                    js = topParams.topBarVals.simple
                } else {
                    if let item = dm.get(tp) {
                        js = item.xml
                    }
                }
                if params != "" {
                    js.params(string: params)
                }
                topConfig(js)
            } else {
                var js = item.xml
                js.params(obj: item)
                topConfig(js)
            }
        }
    }
    
    //MARK: clearing the subviews and view stores
    func clear() {
            self.views = [:]
            self.viewsStore = []
            self.tmpViews = []
            self.totalViews = 0
            self.viewsLoaded = 0
            self.codeDone = true
            for sView in self.view.subviews {
                sView.removeFromSuperview()
            }
    }
    
    // configuring the views (main or subviews)
    
    var views: [String: AmytisViewType] = [:]
    var viewsStore: [AmytisViewType] = []
    var viewsLoaded: Int = 0
    var totalViews: Int = 0
    
    /// initializing plain view
    func plainView(parent: UIView, views: [XML]) {
        self.totalViews = views.count
        self.viewsLoaded = 0
        for xml in views {
            let key = xml.name
            let frame = Frame.create(from: xml, withParent: parent, Aview: self)
            if self.shoudShow(xml), let type = viewType(rawValue: key) {
                self.addView(parent, frame, type, xml)
            }
        }
    }
    
    
    /// add any detectedView
    func addView(_ parent: UIView, _ frame: Frame, _ type: viewType, _ object: XML) {
        switch type {
            case .view:
                    let vv = View(self, frame, object)
                    self.setOptions(object, vv)
            case .label:
                    let label = Label(self, frame, object)
                    self.setOptions(object, label)
            case .image:
                    let image = ImageView(self, frame, object)
                    self.setOptions(object, image)
            case .textfield:
                    let textfield = TextField(self, frame, object)
                    self.setOptions(object, textfield)
            case .button:
                    let button = Button(self, frame, object)
                    self.setOptions(object, button)
            case .list:
                    let table = TableView(self, frame, object)
                    self.setOptions(object, table)
            case .collection:
                    let collection = CollectionView(self, frame, object)
                    self.setOptions(object, collection)
            case .slider:
                    let slider = Slider(self, frame, object)
                    self.setOptions(object, slider)
            case .slideshow:
                    let slider = SlideShow(self, frame, object)
                    self.setOptions(object, slider)
            case .map:
                    let map = Map(self, frame, object)
                    self.setOptions(object, map)
                break;
            case .picker:
                    let picker = Picker(self, frame, object)
                    self.setOptions(object, picker)
            case .gmap:
                    let gmap = GMap(self, frame, object)
                    self.setOptions(object, gmap)
            case .selection:
                    let selection = Segment(self, frame, object)
                    self.setOptions(object, selection)
            case .switchw:
                    let switch2 = Switch(self, frame, object)
                    self.setOptions(object, switch2)
            case .datepicker:
                    let picker = DatePicker(self, frame, object)
                    self.setOptions(object, picker)
            case .webview:
                let web = WebView(self, frame, object)
                self.setOptions(object, web)
        }
    }
    
    
    var tmpViews: [UIView] = []
    
    func setOptions(_ object: XML, _ view: AmytisViewType) {
            var id: String = UUID().uuidString
            object.string([viewParams.id], { (i: String) in
                id = i
                if self.views.keys.contains(id) {
                    id = "\(id)-\(i)"
                    var i2 = 2
                    while (self.views.keys.contains(id)) {
                        id = "\(id)-\(i2)"
                        i2 += 1
                    }
                }
                self.views[id] = view
            })
            view.id = id
            if let v = view as? UIView {
                self.tmpViews.append(v)
            }
            self.viewsStore.append(view)
    }
    
    
    /// detect if to include a view from file
    func detectInclude(xml: XML) -> (String, XML){
        let key = xml.name
        if viewType(rawValue: key) == nil {
            if let xm = dm.get(key, replaceAttr: xml.attributes, addChildren: xml.children, str: xml.value) {
                if viewType(rawValue: xm.name) == nil {
                    return detectInclude(xml: xm)
                } else {
                    return (xm.name, xm)
                }
            }
        }
        return (key, xml)
    }
    
    // detect if the view should be added or not
    func shoudShow(_ object: XML) -> Bool {
        var show = true
        object.string(viewParams.show, {(sh: String) in
            if sh.compare(viewParams.showTypes.no) {
                show = false
            } else if sh.compare(viewParams.showTypes.yes) {
                show = true
            }
        })
        return show
    }
    
    public func switchViews(_ toShow: String, _ toHide: String) {
        self.animateViews(toShow, [toHide])
    }
    
    public func animateViews(_ toShow: String, _ toHide: [String], right: Bool = true, speed: Int = 10, completion: (() -> Void)? = nil) {
        runAsync {
            for name in toHide {
                if let v = self.views[name] as? UIView {
                    if !v.isHidden {
                        var frame2 = v.frame
                        UIView.animate(withDuration: Double(5.0/Double(speed)), animations: {
                            if right {
                                v.frame.origin = CGPoint(x: -v.frame.size.width , y: v.frame.origin.y)
                            } else {
                                v.frame.origin = CGPoint(x:self.view.frame.size.width , y: v.frame.origin.y)
                            }
                        }, completion: {yes in v.isHidden = true;v.frame = frame2})
                    }
                }
            }
            if let v = self.views[toShow] as? UIView {
                var frame2 = v.frame
                if right {
                    v.frame.origin = CGPoint(x:self.view.frame.size.width , y: v.frame.origin.y)
                } else {
                    v.frame.origin = CGPoint(x: -v.frame.size.width , y: v.frame.origin.y)
                }
                v.isHidden = false
                UIView.animate(withDuration: Double(5.0/Double(speed)), animations: {v.frame = frame2}, completion: {vool in
                    if let completion = completion {
                        completion()
                    }
                })
            }
        }
    }
    
    
    ///// view loading config 
    
    var loading: UIActivityIndicatorView?
    
    public func startLoading() {
        self.loading = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.frame.size))
        if let loading = loading {
            loading.color = .black
            loading.backgroundColor = UIColor.groupTableViewBackground
            self.runAsync {self.view.addSubview(loading)}
            loading.startAnimating()
        }
    }
    
    public func stopLoading() {
        loading?.stopAnimating()
        self.runAsync {self.loading?.removeFromSuperview()}
    }
    
    
//getting the views
    
    public func view(_ id: String) -> View? {
        if let view = views[id] as? View {
            return view
        }
        return nil
    }
    
    public func label(_ id: String) -> Label? {
        if let label = views[id] as? Label {
            return label
        }
        return nil
    }
    
    public func image(_ id: String) -> ImageView? {
        if let image = views[id] as? ImageView {
            return image
        }
        return nil
    }
    
    public func button(_ id: String) -> Button? {
        if let btn = views[id] as? Button {
            return btn
        }
        return nil
    }
    
    public func textfield(_ id: String) -> TextField? {
        if let textfield = views[id] as? TextField {
            return textfield
        }
        return nil
    }
    
    public func tableview(_ id: String) -> TableView? {
        if let tableview = views[id] as? TableView {
            return tableview
        }
        return nil
    }
    
    public func collectionview(_ id: String) -> CollectionView? {
        if let collectionview = views[id] as? CollectionView {
            return collectionview
        }
        return nil
    }
    
    public func map(_ id: String) -> Map? {
        if let map = views[id] as? Map {
            return map
        }
        return nil
    }
    
    public func picker(_ id: String) -> Picker? {
        if let picker = views[id] as? Picker {
            return picker
        }
        return nil
    }
    
    public func selection(_ id: String) -> Segment? {
        if let segment = views[id] as? Segment {
            return segment
        }
        return nil
    }
    
    public func slider(_ id: String) -> Slider? {
        if let slider = views[id] as? Slider {
            return slider
        }
        return nil
    }
    
    public func slideshow(_ id: String) -> SlideShow? {
        if let slideshow = views[id] as? SlideShow {
            return slideshow
        }
        return nil
    }
    
    public func getSwitch(_ id: String) -> Switch? {
        if let switchw = views[id] as? Switch {
            return switchw
        }
        return nil
    }
    
    public func datepicker(_ id: String) -> DatePicker? {
        if let datepicker = views[id] as? DatePicker {
            return datepicker
        }
        return nil
    }
    
    ///////// using views by closure
    
    public func view(_ id: String, _ closure: @escaping (View) -> Void) {
        if let item = views[id] as? View {
            closure(item)
        }
    }
    
    public func label(_ id: String, _ closure: @escaping (Label) -> Void) {
        if let item = views[id] as? Label {
            closure(item)
        }
    }
    
    public func image(_ id: String, _ closure: @escaping (ImageView) -> Void) {
        if let item = views[id] as? ImageView {
            closure(item)
        }
    }
    
    public func button(_ id: String, _ closure: @escaping (Button) -> Void) {
        if let item = views[id] as? Button {
            closure(item)
        }
    }
    
    public func textfield(_ id: String, _ closure: @escaping (TextField) -> Void) {
        if let item = views[id] as? TextField {
            closure(item)
        }
    }
    
    public func tableview(_ id: String, _ closure: @escaping (TableView) -> Void) {
        if let item = views[id] as? TableView {
            closure(item)
        }
    }
    
    public func collectionview(_ id: String, _ closure: @escaping (CollectionView) -> Void) {
        if let item = views[id] as? CollectionView {
            closure(item)
        }
    }
    
    public func map(_ id: String, _ closure: @escaping (Map) -> Void) {
        if let item = views[id] as? Map {
            closure(item)
        }
    }
    
    public func picker(_ id: String, _ closure: @escaping (Picker) -> Void) {
        if let item = views[id] as? Picker {
            closure(item)
        }
    }
    
    public func selection(_ id: String, _ closure: @escaping (Segment) -> Void) {
        if let item = views[id] as? Segment {
            closure(item)
        }
    }
    
    public func slider(_ id: String, _ closure: @escaping (Slider) -> Void) {
        if let item = views[id] as? Slider {
            closure(item)
        }
    }
    
    public func slideshow(_ id: String, _ closure: @escaping (SlideShow) -> Void) {
        if let item = views[id] as? SlideShow {
            closure(item)
        }
    }
    
    public func getSwitch(_ id: String, _ closure: @escaping (Switch) -> Void) {
        if let item = views[id] as? Switch {
            closure(item)
        }
    }
    
    public func datepicker(_ id: String, _ closure: @escaping (DatePicker) -> Void) {
        if let item = views[id] as? DatePicker {
            closure(item)
        }
    }
    
    //nonview functions
    
    func currentTimeMillis() -> Double{
        let nowDouble = NSDate().timeIntervalSince1970
        return nowDouble*1000
    }
    
    /////// gestures handler
    
    
    func configureSwipeGestures(_ direction: UISwipeGestureRecognizer.Direction) {
        let sw = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        gestureRecognizers.append(sw)
        sw.direction = direction
        view.addGestureRecognizer(sw)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        runAsync {
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                switch swipeGesture.direction {
                    case UISwipeGestureRecognizer.Direction.right:
                        self.swipe.right()
                    case UISwipeGestureRecognizer.Direction.down:
                        self.swipe.down()
                    case UISwipeGestureRecognizer.Direction.left:
                        self.swipe.left()
                    case UISwipeGestureRecognizer.Direction.up:
                        self.swipe.right()
                    default:
                        break
                }
            }
        }
    }
    
    func configurePan() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        if gestureRecognizer.state == .began {
            pan.began?()
            pan.beganOn?(translation)
        }
        if gestureRecognizer.state == .changed {
            pan.changed?(translation)
        }
        if gestureRecognizer.state == .ended {
            pan.ended?()
            pan.endedOn?(translation)
        }
    }
    
    public func bindToPan(view: UIView, end: CGPoint = CGPoint.zero, direction: BindPanDirection = .x, incremental: Bool = false, ended: (() -> Void)? = nil) {
        configurePan()
        let _ended = {
            self.pan.began = nil
            self.pan.ended = nil
            self.pan.changed = nil
            ended?()
        }
        var end = end
        let frame = view.frame
        if end == CGPoint.zero {
            if incremental {
                end = CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y + frame.size.height)
            } else {
                end = CGPoint(x: frame.origin.x - frame.size.width, y: frame.origin.y - frame.size.height)
            }
        }
        if direction == .x {
            let way: CGFloat = -(frame.origin.x - end.x)
            var x: CGFloat = 0
            var done = false
            pan.changed {point in
                x = point.x
                if ((point.x > 0 && incremental) || (point.x < 0 && !incremental)) {
                    if !done, ((x <= way && incremental) || (x >= way && !incremental)) {
                        view.frame.origin = CGPoint(x: frame.origin.x + x, y: view.frame.origin.y)
                    } else {
                        done = true
                    }
                }
            }
            pan.ended {
                if !done {
                    if ((x >= (way/2) && incremental) || (x <= (way/2) && !incremental)) {
                        UIView.animate(withDuration: 0.2, animations: {view.frame.origin = CGPoint(x: end.x, y: view.frame.origin.y)}, completion: {_ in
                            _ended()
                        })
                    } else {
                        UIView.animate(withDuration: 0.2) {view.frame.origin = frame.origin}
                    }
                } else {
                    if end.x - view.frame.origin.x > 0 {
                        UIView.animate(withDuration: 0.05) {view.frame.origin = CGPoint(x: end.x, y: view.frame.origin.y)}
                    }
                    _ended()
                }
            }
        }
        else if direction == .y {
            let way: CGFloat = -(frame.origin.y - end.y)
            var y: CGFloat = 0
            var done = false
            pan.changed {point in
                y = point.y
                if ((point.y > 0 && incremental) || (point.y < 0 && !incremental)) {
                    if !done, ((y <= way && incremental) || (y >= way && !incremental)) {
                        view.frame.origin = CGPoint(x: view.frame.origin.x, y: frame.origin.y + y)
                    } else {
                        done = true
                    }
                }
            }
            pan.ended {
                if !done {
                    if ((y >= (way/2) && incremental) || (y <= (way/2) && !incremental)) {
                        UIView.animate(withDuration: 0.2, animations: {view.frame.origin = CGPoint(x: view.frame.origin.x, y: end.y)}, completion: {_ in
                            _ended()
                        })
                    } else {
                        UIView.animate(withDuration: 0.2) {view.frame.origin = frame.origin}
                    }
                } else {
                    if end.x - view.frame.origin.x > 0 {
                        UIView.animate(withDuration: 0.05) {view.frame.origin = CGPoint(x: view.frame.origin.x, y: end.y)}
                    }
                    _ended()
                }
            }
        }
    }
    
}

public enum BindPanDirection: Int {
    case x
    case y
    case xy
}


import JavaScriptCore

// accessing object of AmytisView from js code
@objc public protocol AmytisViewJSExport: JSExport {
    func label(_ id: String) -> Label?
    func image(_ id: String) -> ImageView?
    func view(_ id: String) -> View?
    func button(_ id: String) -> Button?
    func textfield(_ id: String) -> TextField?
    func tableview(_ id: String) -> TableView?
    func collectionview(_ id: String) -> CollectionView?
    func map(_ id: String) -> Map?
    func picker(_ id: String) -> Picker?
    func selection(_ id: String) -> Segment?
    func slider(_ id: String) -> Slider?
    func slideshow(_ id: String) -> SlideShow?
    func getSwitch(_ id: String) -> Switch?
    func datepicker(_ id: String) -> DatePicker?
    
    func open(_ name: String, _ params: [String: Any]?)
    func switchViews(_ toShow: String, _ toHide: String)
}

public class Pan: NSObject {
    var began: (() -> Void)?
    var beganOn: ((CGPoint) -> Void)?
    var ended: (() -> Void)?
    var endedOn: ((CGPoint) -> Void)?
    var changed: ((CGPoint) -> Void)?
    
    public func began(_ s: @escaping (() -> Void)) {
        self.began = s
    }
    public func beganOn(_ s: @escaping ((CGPoint) -> Void)) {
        self.beganOn = s
    }
    public func ended(_ s: @escaping (() -> Void)) {
        self.ended = s
    }
    public func endedOn(_ s: @escaping ((CGPoint) -> Void)) {
        self.endedOn = s
    }
    public func changed(_ s: @escaping ((CGPoint) -> Void)) {
        self.changed = s
    }
}


public class Swipe: NSObject {
    var _left: (() -> Void)?
    var _right: (() -> Void)?
    var _up: (() -> Void)?
    var _down: (() -> Void)?
    
    func left() {
        if let s = self._left {
            s()
        }
    }
    func right() {
        if let s = self._right {
            s()
        }
    }
    func up() {
        if let s = self._up {
            s()
        }
    }
    func down() {
        if let s = self._down {
            s()
        }
    }
    
    public func left(_ s: @escaping (() -> Void)) {
        self._left = s
    }
    public func right(_ s: @escaping (() -> Void)) {
        self._right = s
    }
    public func up(_ s: @escaping (() -> Void)) {
        self._up = s
    }
    public func down(_ s: @escaping (() -> Void)) {
        self._down = s
    }
}
