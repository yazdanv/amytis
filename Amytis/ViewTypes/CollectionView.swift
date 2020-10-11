//
//  CollectionView.swift
//  Alamofire
//
//  Created by Yazdan on 6/16/17.
//

import UIKit

public class CollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, AmytisViewType, JSCollectionExport, UIGestureRecognizerDelegate, ExtendableView {
    

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
    
    var layout: UICollectionViewFlowLayout!
    
    var _onSelect: JSValue?
    var _onSelect2: ((IndexPath) -> Void)?
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
    
    
    var _onLongPress: JSValue? {didSet {configLongPressGesture()}}
    var _onLongPress2: ((IndexPath) -> Void)? {didSet {configLongPressGesture()}}
    public var onLongPress: Any {
        set {
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
    var _cellStorage: [IndexPath: UIView] = [:]
    var _cells: [[JSON]] = []
    var _cell = [String: String]()
    var _cellBack = [String: UIColor]()
    
    var headerID: [Int: String] = [:]
    var header: [String: String] = [:]
    var headerHeight: [String: Int] = [:]
    var headerIdForSection: ((Int) -> String?)?
    var headerIdForSection2: ((Int) -> (String, ((AmytisView) -> Void))?)?
    var _headerIdForSection: [Int: String] = [:]
    var isRtl = false
    public var __headerForSection: [Int: ((AmytisView) -> Void)] = [:]
    var storage = true
    
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

    public func reload(index: IndexPath) {
        reloadCells()
        _cellStorage[index] = nil
        self.reloadItems(at: [index])
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
                for item in 0...(val - 1) {
                    let index = IndexPath(row: item, section: key)
                    let (id, cell) = cfi(index)
                    __cellForIndex[index] = cell
                    _cellIdForIndex[index] = id
                }
            }
        }
    }
    var rowFrames = [String: Frame]()
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
    
    public var staticCount = 0 {
        didSet {
            self.reload()
        }
    }
    var staticSize = CGSize(width: 44, height: 44)
    
    
    convenience init(_ parent: AmytisView, _ rect: Frame, _ object: XML) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        object.string(listParams.direction) {dir in
            if dir.compare(listParams.directions.horizontal) {
                layout.scrollDirection = .horizontal
            }
        }
        object.no(listParams.directions.vertical) {layout.scrollDirection = .horizontal}
        self.init(frame: CGRect(origin: rect.origin, size: rect.size), collectionViewLayout: layout)
        self.setViewParams(object, parent)
        self.viewXML = object
        self.parent = parent
        self.layout = layout
        self.register(ModelCollectionCell.self, forCellWithReuseIdentifier: "cell")
        self.frame2 = rect
        //self.separatorStyle = .none
        self.delegate = self
        self.dataSource = self
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
        rowFrames = [:]
        jsons = [:]
    }
    
    func empty() {
        _cellStorage = [:]
        _cells = []
        _cell = [:]
        _cellBack = [:]
        rowCount = [:]
        rowFrames = [:]
        jsons = [:]
    }
    
    public func config() {
        for item in viewXML.children {
            var (key, xml) = parent.detectInclude(xml: item)
            var id = "default"
            xml.string(viewParams.type, {type in key = type})
            xml.string(viewParams._id, { _id in id = _id})
            if key.compare(listParams.cell) {
                self._cell[id] = xml.xml
                let frame = Frame.create(from: xml, withParent: self)
                self.rowFrames[id] = frame
                self.layout.itemSize = frame.size
                self.collectionViewLayout = self.layout
                xml.string(viewParams.backgroundColor, {(colorName: String) in
                    self._cellBack[id] = UIColor.pickColor(colorName)
                })
            } else if key.compare(listParams.header) {
                self.header[id] = xml.xml
                xml.int(["section"], {(sec: Int) in
                    self.headerID[sec] = id
                })
                xml.int(viewParams.height, {(height: Int) in
                    self.headerHeight[id] = height
                })
            }
        }
        viewXML.yes(["rtl"], {
            self.isRtl = true
        })
        viewXML.xml(listParams.fromJson, {(options: XML) in
            var (url, method, parameters, listname): (String, String, [String: Any], String) = ("", "get", [:], "")
            options.string(listParams.url, {(ur: String) in
                url = ur
            })
            options.string(listParams.method , {(ur: String) in
                method = ur
            })
            options.string(["listname"], {name in
                listname = name
            })
            options.xml(viewParams.params, {(params: XML) in
                parameters = params.attributes
            })
            if url != "" {
                self.startLoading()
                RH.json(url, parameters, method: method == "get" ? .get:.post, object: {jsn in
                    self.jsons[0] = jsn[listname].array
                    self.stopLoading()
                }, array: {jsonArray in
                    self.jsons[0] = jsonArray
                    self.stopLoading()
                })
            }
        })
        viewXML.string(actionParams.clicked, {act in
            if let ac = parent.controller.context.objectForKeyedSubscript(act) {
                _onSelect = ac
            }
        })
        viewXML.double(viewParams.itemSpace, {space in
            layout.minimumInteritemSpacing = CGFloat(space)
            self.collectionViewLayout = layout
        })
        viewXML.double(viewParams.lineSpace, {space in
            layout.minimumLineSpacing = CGFloat(space)
            self.collectionViewLayout = layout
        })
//        viewXML.string(actionParams.clicked, {act in
//            if let ac = parent.controller.context.objectForKeyedSubscript(act) {
//                _onReady = ac
//            }
//        })
        viewXML.bool(listParams.storage) {store in
            self.storage = store
        }
        if isRtl {
            self.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configLongPressGesture() {
        var duration = 0.5
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
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if rowCount.keys.count > 0 {
            return rowCount.keys.count
        }
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = rowCount[section] {
            return count
        }
        return staticCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return _cellSize(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func _cellSize(_ indexPath: IndexPath) -> CGSize {
        if let id = _cellIdForIndex[indexPath] {
            if let frame = rowFrames[id] {
                return frame.size
            }
        } else if let key = self._cell.keys.first, let frame = rowFrames[key] {
            return frame.size
        }
        return staticSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, heightForHeaderInSection section: Int) -> CGFloat {
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
    
    public func collectionView(_ collectionView: UICollectionView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        _cell.backgroundColor = .clear
        let size: CGSize = _cellSize(indexPath)
        var view: UIView?
//        if _cellStorage[indexPath] == nil {
            view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let AmytisView = view!.createAmytisView(parent: self.parent)
            AmytisView.viewDidLoad = {
                if let cell = self.__cellForIndex[indexPath] {
                    cell(AmytisView)
                } else if let cell = self.__cell {
                    cell(AmytisView, indexPath)
                }
            }
            var cell_id = "default"
            if let id = self._cellIdForIndex[indexPath] {
                cell_id = id
            }
            let cl: String? = self._cell[cell_id]
            if let cl = cl {
                var _cellString = cl
                if let json = jsons[indexPath.section]?[indexPath.item] {
                    _cellString.params(objects: json)
                }
                do {
                    let xml_cell = try XMLDocument(xml: _cellString).root
                    view!.setViewParams(xml_cell, AmytisView, padding: true)
                    AmytisView.populateWith(xmlArr: xml_cell.children)
                    _cell.subviews.forEach {v in v.removeFromSuperview()};_cell.addSubview(view!)
                } catch{}
            }
            _cellStorage[indexPath] = view!
//        }
        if self.isRtl {view?.transform = CGAffineTransform(scaleX: -1, y: 1)}
        return _cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let (row, component) = (indexPath.row, indexPath.section)
        if let _onSelect = _onSelect {
            if let dic = jsons[component]?[row].dictionaryValue {
                _ = _onSelect.call(withArguments: [row, component, dic])
            } else {
                _ = _onSelect.call(withArguments: [row, component])
            }
        } else if let _onSelect = _onSelect2 {
            _onSelect(indexPath)
        }
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            return
        }
        let p = gestureReconizer.location(in: self)
        let indexPath = self.indexPathForItem(at: p)
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

class ModelCollectionCell: UICollectionViewCell {}


////////////////////////////////////////
import JavaScriptCore

@objc public protocol JSCollectionExport: JSExport {
    var onSelect: Any { get set }
    var onReady: JSValue { get set }
    var staticCount: Int { get set }
    var rowCount: [Int: Int] { get set }
    func configCell(_ comp: JSValue)
    func onSelectCell(_ comp: JSValue)
}

extension CollectionView {
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

