    //
//  TableView.swift
//  Pods
//
//  Created by Yazdan on 4/7/17.
//
//

import UIKit
import JavaScriptCore

public class TableView: UITableView, UITableViewDelegate, UITableViewDataSource, AmytisViewType, JSTableExport, UIGestureRecognizerDelegate, ExtendableView {
    
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
    
    var _nowSlide: Int = 0 {
        didSet{
            slider = true
            self.reload(index: IndexPath(row: 0, section: 0))
        }
    }
    var slider: Bool = false
    
    var _onSelect: JSValue? {didSet {configLongPressGesture()}}
    var _onSelect2: ((IndexPath) -> Void)? {didSet {configLongPressGesture()}}
    public var onSelect: Any {
        set {
            if let val = newValue as? JSValue {
                _onSelect = val
            } else if let val = newValue as? ((IndexPath) -> Void) {
                _onSelect2 = val
            }
        }
        get {
            return JSValue()
        }
    }
    
    public func onSelect(_ action: @escaping ((IndexPath) -> Void)) {
        self._onSelect2 = action
    }
    
    
    var _onLongPress: JSValue?
    var _onLongPress2: ((IndexPath) -> Void)?
    public var onLongPress: Any {
        set {
            configLongPressGesture()
            if let val = newValue as? JSValue {
                _onLongPress = val
            } else if let val = newValue as? ((IndexPath) -> Void) {
                _onLongPress2 = val
            }
        }
        get {
            return JSValue()
        }
    }
    
    public func onLongPress(_ action: @escaping ((IndexPath) -> Void)) {
        self._onLongPress2 = action
    }
    
    
    var _onReady: JSValue?
    public var onReady: JSValue {
        set {
            _onReady = newValue
        }
        get {
            return JSValue()
        }
    }
    
    var cellIdForIndex: ((IndexPath) -> String)?
    var cellIdForIndex2: ((IndexPath) -> (String, ((AmytisView) -> Void)))?
    var _cellIdForIndex: [IndexPath: String] = [:]
    var _didDisplayCell: ((IndexPath) -> Void)?
    var _cellStorage: [IndexPath: UITableViewCell] = [:]
    var _cells: [[JSON]] = []
    var _cell = [String: String]()
    var _cellBack = [String: UIColor]()
    
    var headerID: [Int: String] = [:]
    var header: [String: String] = [:]
    var headerHeight: [String: Int] = [:]
    var headerIdForSection: ((Int) -> String?)?
    var headerIdForSection2: ((Int) -> (String, ((AmytisView) -> Void))?)?
    var _headerIdForSection: [Int: String] = [:]
    public var __headerForSection: [Int: ((AmytisView) -> Void)] = [:]
    var storage = true
    var demo = false
    
    public var __cell: ((AmytisView, IndexPath) -> Void)?
    public var __cellForIndex: [IndexPath: ((AmytisView) -> Void)] = [:]
    
    
    
    public func cell(_ cell: @escaping ((AmytisView, IndexPath) -> Void)) {
        self.__cell = cell
    }
    
    public var rowCount = [Int: Int]() {
        didSet {
            reload()
        }
    }
    public func reload() {
        reloadCells()
        _cellStorage = [:]
        self.reloadData()
    }
    public func reload(index: IndexPath, animation: UITableView.RowAnimation = .left) {
        reloadCells()
        _cellStorage[index] = nil
        self.reloadRows(at: [index], with: animation)
    }
    func reloadCells() {
        if let cfi = cellIdForIndex {
            for (key, val) in rowCount {
                for item in 0...(val - 1) {
                    let index = IndexPath(row: item, section: key)
                    _cellIdForIndex[index] = cfi(index)
                }
            }
        } else if let cfi = cellIdForIndex2 {
            for (key, val) in rowCount {
                if val > 0 {
                    for item in 0...(val - 1) {
                        let index = IndexPath(row: item, section: key)
                        let (id, cell) = cfi(index)
                        __cellForIndex[index] = cell
                        _cellIdForIndex[index] = id
                    }
                }
            }
        }
    }
    public var rowHeights = [String: Int]()
    public var rowHeightForIndex = [IndexPath: Int]()
    var jsons = [Int: [JSON]]() {
        didSet {
            if jsons.count == 1 {
                self.staticCount = (jsons[0]?.count)!
            } else {
                for (key, value) in jsons {
                    self.rowCount[key] = value.count
                }
            }
            self.reloadData()
        }
    }
    
    public var staticCount = 0 { didSet { self.reloadData() } }
    public var staticHeight = 44
    
    
    convenience init(_ parent: AmytisView, _ rect: Frame, _ object: XML, slider: Bool = false) {
        self.init(frame: CGRect(origin: rect.origin, size: rect.size))
        self.frame2 = rect
        self.viewXML = object
        self.parent = parent
        self.setViewParams(object, parent)
        self.separatorStyle = .none
        self.delegate = self
        self.dataSource = self
        self.slider = slider
        self.loading = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame2.size))
        self.config()
        frame2.rotate = {self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin}
    }
    
    deinit {
        _cellStorage = [:]
        _cells = []
        _cell = [:]
        _cellBack = [:]
        rowCount = [:]
        rowHeights = [:]
        jsons = [:]
    }
    
    func empty() {
        _cellStorage = [:]
        _cells = []
        _cell = [:]
        _cellBack = [:]
        rowCount = [:]
        rowHeights = [:]
        jsons = [:]
    }
    
    public func config() {
        for item in self.viewXML.children {
            var (key, xml) = parent.detectInclude(xml: item)
            var id = "default"
            xml.string(viewParams.type, {type in key = type})
            xml.string(viewParams._id, { _id in id = _id})
            if key.compare(listParams.cell) {
                self._cell[id] = xml.xml
                let frame = Frame.create(from: xml, withParent: self)
                self.rowHeights[id] = Int(frame.size.height)
                xml.string(viewParams.backgroundColor, {(colorName: String) in
                    self._cellBack[id] = UIColor.pickColor(colorName)
                })
            } else if key.compare(listParams.header) {
                self.header[id] = xml.xml
                xml.int(["section"], {(sec: Int) in
                    self.headerID[sec] = id
                })
                let frame = Frame.create(from: xml, withParent: self)
                self.headerHeight[id] = Int(frame.size.height)
            } else if key.compare(listParams.slide) {
                self._cell[id] = xml.xml
                self.rowHeights[id] = Int(self.frame2.size.height)
                xml.string(viewParams.backgroundColor, {(colorName: String) in
                    self._cellBack[id] = UIColor.pickColor(colorName)
                })
            }
        }
        
        self.viewXML.xml(listParams.fromJson, {(options: XML) in
            var (url, method, parameters): (String, String, [String: Any]) = ("", "get", [:])
            options.string(listParams.url, {(ur: String) in
                url = ur
            })
            options.string(listParams.method , {(ur: String) in
                method = ur
            })
            options.xml(viewParams.params, {(params: XML) in
                parameters = params.attributes
            })
            if url != "" {
                self.startLoading()
//                AH.requestJsonArray(url, method, parameters, {(json: [JSON]) in
//                    self.jsons[0] = json
//                    self.stopLoading()
//                }, {})
            }
        })
        self.viewXML.string(actionParams.clicked, {act in
            if parent.controller != nil, let ac = parent.controller.context.objectForKeyedSubscript(act) {
                _onSelect = ac
            }
        })
//        viewXML.string(actionParams.clicked, {act in
//            if parent.controller != nil, let ac = parent.controller.context.objectForKeyedSubscript(act) {
//                _onReady = ac
//            }
//        })
        self.viewXML.bool(listParams.storage) {store in
            self.storage = store
        }
        self.viewXML.bool(listParams.demo) {demo in
            if demo {
                self.demo = demo
                if _cell.keys.count == 1 {
                    self.staticCount = 1
                } else if _cell.keys.count > 1 {
                    var list: [String] = []
                    _cell.keys.forEach {list.append($0)}
                    self.cellIdForIndex {index in return list[index.row]}
                    self.rowCount[0] = list.count
                }
            }
        }
        self.bounces = true
        self.viewXML.no(listParams.bounce) {self.bounces = false}
    }
    
    
    func configLongPressGesture() {
        var duration = 1.0
        viewXML.double(listParams.longPressDuration) {duration = $0}
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = duration
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.addGestureRecognizer(lpgr)
    }
    
    
    var loading: UIActivityIndicatorView?

    public func startLoading() {
        self.loading = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame2.size))
        if let loading = loading {
            loading.color = .black
            loading.backgroundColor = UIColor.groupTableViewBackground
            self.addSubview(loading)
            loading.startAnimating()
        }
    }
    
    public func stopLoading() {
        if let loading = loading {
            loading.stopAnimating()
            loading.removeFromSuperview()
            self.loading = nil
        }
    }

    
    public func cellIdForIndex(_ action: ((IndexPath) -> String)? = nil) {
        self.cellIdForIndex = action
    }
    public func cellForIndex(_ action: ((IndexPath) -> (String, ((AmytisView) -> Void)))? = nil) {
        self.cellIdForIndex2 = action
    }
    
    public func headerIdForSection(_ action: ((Int) -> String?)? = nil) {
        self.headerIdForSection = action
    }
    public func headerForSection(_ action: ((Int) -> (String, ((AmytisView) -> Void))?)? = nil) {
        self.headerIdForSection2 = action
    }
    
    public func didDisplayCell(_ action: ((IndexPath) -> Void)? = nil) {
        self._didDisplayCell = action
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        if slider {return 1}
        if rowCount.keys.count > 0 {
            return rowCount.keys.count
        }
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if slider {return 1}
        if let count = rowCount[section] {
            return count
        }
        return staticCount
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return _cellHeight(indexPath)
    }
    
    func _cellHeight(_ indexPath: IndexPath) -> CGFloat {
        if let height = rowHeightForIndex[indexPath] {
            return CGFloat(height)
        }
        if let id = _cellIdForIndex[indexPath] {
            if let height = rowHeights[id] {
                return CGFloat(height)
            }
        } else if let height = rowHeights[self._cell.keys.first!] {
            return CGFloat(height)
        }
        return CGFloat(staticHeight)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let id = headerID[section] {
            var height: CGFloat = 44
            if let hg = headerHeight[id] {
                height = CGFloat(hg)
            }
            return height
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let ret: (String, String) -> UIView = {id, head in
            var height: CGFloat = 44
            if let hg = self.headerHeight[id] {
                height = CGFloat(hg)
            }
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: height))
            let xmlv = headerView.createAmytisView(parent: self.parent)
            do {
                let xml_head = try XMLDocument(xml: head).root
                headerView.setViewParams(xml_head, xmlv)
                xmlv.populateWith(xmlArr: xml_head.children)
            } catch{}
            return headerView
        }
        if let id = headerIdForSection?(section), let head = header[id] {
            return ret(id, head)
        } else if let id = headerID[section], let head = header[id] {
            return ret(id, head)
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var index = indexPath
        if slider {
            index = IndexPath(row: _nowSlide, section: 0)
        }
        if storage {
            if let _cell = _cellStorage[index] {
                return _cell
            }
        }
        let _cell = UITableViewCell()
        _cell.backgroundColor = .clear
        _cell.selectionStyle = .none
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: _cellHeight(index)))
        let AmytisView = view.createAmytisView(parent: self.parent)
        AmytisView.viewDidLoad = {
            
            _cell.subviews.forEach {v in v.removeFromSuperview()}
            _cell.addSubview(view)
            if let cell = self.__cellForIndex[index] {
                cell(AmytisView)
            } else if let cell = self.__cell {
                cell(AmytisView, index)
            }
        }
        var cell_id = "default"
        if let id = self._cellIdForIndex[index] {
            cell_id = id
        }
        let cl: String? = self._cell[cell_id]
        if let cl = cl {
            var _cellString = cl
            if let json = jsons[index.section]?[index.row] {
                _cellString.params(objects: json)
            }
            do {
                let xml_cell = try XMLDocument(xml: _cellString).root
                view.setViewParams(xml_cell, AmytisView, padding: true)
                AmytisView.populateWith(xmlArr: xml_cell.children)
            } catch{}
        }
        if storage {
            _cellStorage[index] = _cell
        }
        return _cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (row, component) = (indexPath.row, indexPath.section)
        if let _onSelect = _onSelect {
            if let dic = jsons[component]?[row].dictionaryValue {
                _ = _onSelect.call(withArguments: [indexPath, dic])
            } else {
                _ = _onSelect.call(withArguments: [indexPath])
            }
        } else if let _onSelect = _onSelect2 {
            _onSelect(indexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        _didDisplayCell?(indexPath)
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            return
        }
        let p = gestureReconizer.location(in: self)
        let indexPath = self.indexPathForRow(at: p)
        if let index = indexPath {
            let (row, component) = (index.row, index.section)
            if let _onLongPress = _onLongPress {
                if let dic = jsons[component]?[row].dictionaryValue {
                    _ = _onLongPress.call(withArguments: [row, component, dic])
                } else {
                    _ = _onLongPress.call(withArguments: [row, component])
                }
            } else if let _onLongPress = _onLongPress2 {
                _onLongPress(index)
            }
        }
    }

}
    

    
////////////////////////////////////////
    
    
@objc public protocol JSTableExport: JSExport {
    var onSelect: Any { get set }
    var onReady: JSValue { get set }
    var staticCount: Int { get set }
    var rowCount: [Int: Int] { get set }
    func configCell(_ comp: JSValue)
    func onSelectCell(_ comp: JSValue)
    func cellIdForIndex(_ action: ((IndexPath) -> String)?)
    func headerIdForSection(_ action: ((Int) -> String?)?)
}
    
extension TableView {
    public func configCell(_ comp: JSValue) {
        self.cell {p1, p2 in
            let p3: [String: Any] = ["row": p2.row, "section": p2.section]
            comp.call(withArguments: [p1, p3])
        }
    }
    public func onSelectCell(_ comp: JSValue) {
        self.onSelect {p in
            let param: [String: Any] = ["row": p.row, "section": p.section]
            comp.call(withArguments: [param])
        }
    }
}

