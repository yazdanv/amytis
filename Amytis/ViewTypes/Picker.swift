//
//  GMap.swift
//  Pods
//
//  Created by Yazdan on 5/7/17.
//
//

import UIKit
import JavaScriptCore

@objc public protocol JSPickerExport: JSExport {
    var onSelect: Any { get set }
    var _onSelect: JSValue? { get set }
    var _onSelect2: ((Int, Int) -> Void)? { get set }
    func titles(_ component: Int, _ titles: [String])
    func select(_ component: Int, _ row: Int)
}

public final class Picker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource, AmytisViewType, JSPickerExport, ExtendableView {
  
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
    @objc public func reRenderWithChild(_ xml: String) {_reRender(xml)}
    @objc public func reRender(_ params: [String: Any]) {_reRender(params)}
    @objc public func reCalculateFrame(_ animated: Bool) {_reCalculateFrame(animated)}
    @objc public func animateToFrame(_ string: String, _ time: Double = 0.5, _ completion: JSValue? = nil) {
        _ = animateToFrame(string, time, {_ = completion?.call(withArguments: [])})
    }
    ///////////////////////////////////////////////
    public func rowHeight(_ height: Int) -> Picker {
        self.staticHeight = height
        return self
    }
    ///////////////////////////////////////////////
    
    public var _onSelect: JSValue?
    public var _onSelect2: ((Int, Int) -> Void)?
    public var onSelect: Any {
        set {
            if let val = newValue as? JSValue {
                _onSelect = val
            } else if let val = newValue as? ((Int, Int) -> Void) {
                _onSelect2 = val
            }
        }
        get {
            return JSValue()
        }
    }
    
    public func onSelect(_ action: @escaping (Int, Int) -> Void) {
        self.onSelect = action
    }
    
    var cells: [[JSON]] = []
    var cell = [Int: String]()
    var cellBack = [Int: UIColor]()
    var titleList = [Int: [String]]()
    
    
    var rowCount = [Int: Int]()
    var rowHeights = [Int: [Int: Int]]()
    var jsons = [Int: [JSON]]() {
        didSet {
            if jsons.count == 1 {
                self.staticCount = (jsons[0]?.count)!
            } else {
                for (key, value) in jsons {
                    self.rowCount[key] = value.count
                }
            }
            self.reloadAllComponents()
        }
    }
    
    var staticCount = 0
    var staticHeight = 44
    
    
    convenience init(_ parent: AmytisView, _ rect: Frame, _ object: XML) {
        self.init(frame: CGRect(origin: rect.origin, size: rect.size))
        self.viewXML = object
        self.parent = parent
        self.frame2 = rect
        self.setViewParams(object, parent)
        requiredInit()
        self.config()
        frame2.rotate = {self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin}
    }
    
    public func requiredInit() {
        self.delegate = self
        self.dataSource = self
    }
    
    deinit {
        cells = []
        cell = [:]
        cellBack = [:]
        rowCount = [:]
        rowHeights = [:]
        jsons = [:]
    }
    
    func empty() {
        frame2.empty()
        cells = []
        cell = [:]
        cellBack = [:]
        rowCount = [:]
        rowHeights = [:]
        jsons = [:]
    }
    
    public func config() {
        var i = 0
        self.viewXML.xml(listParams.cell, {(cell: XML) in
            self.cell[i] = cell.xml
            cell.int(viewParams.height, {(height: Int) in
                self.staticHeight = height
            })
            cell.string(viewParams.backgroundColor, {(colorName: String) in
                self.cellBack[i] = UIColor.pickColor(colorName)
            })
        })
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
                var loading: UIActivityIndicatorView? = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame2.size))
                loading!.color = .black
                loading!.backgroundColor = UIColor.groupTableViewBackground
                self.runAsync {self.addSubview(loading!)}
                loading!.startAnimating()
//                AH.requestJsonArray(url, method, parameters, {(json: [JSON]) in
//                    self.jsons[0] = json
//                    loading!.stopAnimating()
//                    loading!.removeFromSuperview()
//                    loading = nil
//                }, {})
            }
        })
        self.viewXML.int(listParams.rowHeight, {height in
            staticHeight = height
        })
        self.viewXML.string(actionParams.clicked, {act in
            if self.parent.controller != nil, let ac = self.parent.controller.context.objectForKeyedSubscript(act) {
                _onSelect = ac
            }
        })
        func setTitles(_ component: Int, _ object: XML) {
            titleList[component] = []
            if let titles = object["title"].all {
                for title in titles {
                    titleList[component]?.append(title.str)
                }
                rowCount[component] = titles.count
                cell[component] = "<cell><label frame=\"full\" text=\"title\" ts=\"f7\"/></cell>"
            }
            self.reloadAllComponents()
        }
        setTitles(0, self.viewXML)
        
        //        for (key, value) in rowCount {
        //            for _ in 0...(value-1) {
        //                rowHeights[key]?[value] = 44
        //            }
        //        }
    }
    
    public func titles(_ component: Int, _ titles: [String]) {
        titleList[component] = []
        for title in titles {
            titleList[component]?.append(title)
        }
        rowCount[component] = titles.count
        if cell[component] == nil {cell[component] = "<cell><label frame=\"full\" text=\"title\" ts=\"f7\"/></cell>"}
        self.reloadAllComponents()
    }
    
    public func select(_ component: Int, _ row: Int) {
        self.selectRow(row, inComponent: component, animated: true)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let count = rowCount[component] {
            return count
        }
        return staticCount
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return frame.size.width
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let title = titleList[component]?[row] {
            return title
        }
        return ""
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: cellHeight(row, component)))
        let AmytisView = view.createAmytisView(parent: self.parent)
        if let cl = self.cell[component] {
            var cellString = cl
            if let list = titleList[component], list.count > 0 {
                let title = list[row]
                cellString = cellString.replacingOccurrences(of: "title", with: title)
            }
            if let json = jsons[component]?[row] {
                cellString.params(objects: json)
            }
            do {
                let xmlCell = try XMLDocument(xml: cellString).root
                AmytisView.populateWith(xmlArr: xmlCell.children)
            } catch{}
        }
        if let color = cellBack[component] {
            self.runAsync {AmytisView.view.backgroundColor = color}
        }
        return view
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return cellHeight(0, component)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let _onSelect = _onSelect {
        if let dic = jsons[component]?[row].dictionaryValue {
            _ = _onSelect.call(withArguments: [row, component, dic])
        } else {
            _ = _onSelect.call(withArguments: [row, component])
        }
        } else if let _onSelect = _onSelect2 {
            _onSelect(component, row)
        }
    }
    
    func cellHeight(_ row: Int, _ component: Int) -> CGFloat {
        if let height = rowHeights[component]?[row] {
            return CGFloat(height)
        }
        return CGFloat(staticHeight)
    }

}
