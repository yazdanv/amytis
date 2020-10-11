//
//  DataManager.swift
//  Pods
//
//  Created by Yazdan on 4/23/17.
//
//

import Foundation

var dm = DataManager.instance

class DataManager: NSObject {
    
    static var instance = DataManager()
    
    override init() {
        super.init()
        loadAdditions()
        self.load()
        self.priodicSaving()
    }
    
    func priodicSaving() {
        self.save()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0, execute: {self.priodicSaving()})
    }
    
    var xmls: [String: XML] = [:]
    var codes: [String: XML] = [:]
    var topBars: [String: XML] = [:]
    var AmytisViews: [String: AmytisController] = [:]
    var currentController: AmytisController?
    var currentView: AmytisView?
    var usageCount: [String: Int] = [:]
    
    func getUsageCount(_ key: String) -> Int {
        if let count = usageCount[key] {
            return count
        }
        return 0
    }
    
    
    let u = UserDefaults.standard
    var socket: SocketConnection?
    var connected: Bool = false
    
    
    func initSocket(add: Address) {
        socket = SocketConnection(add.host, add.port, sendDelay: 1)
        socket?.onConnected {
            self.connected = true
            self.sendToServer("requestFiles", "")
        }
        socket?.onData(action: {data in
            do {
                let json = try JSON(data: data)
                if json != JSON.null {
                    if let event = json["event"].string {
                        switch (event) {
                        case "data":
                            if let text = json["data"].string {
                                var txt = text.replacingOccurrences(of: catchPhrases.valueDividerShow, with: catchPhrases.valueDivider)
                                if !txt.contains("&amp;") {
                                    txt = txt.replacingOccurrences(of: "&", with: "&amp;")
                                }
                                self.handle(text: txt)
                            }
                        case "image":
                            var window = 1
                            var quality = 10
                            if let wn = json["data"]["window"].int, let q = json["data"]["quality"].int {
                                window = wn
                                quality = q
                            }
                            self.sendScreen(window, Double(quality/100))
                        case "saveImage":
                            if let name = json["data"]["name"].string, let data = json["data"]["data"].string {
                                Image.save(name, Image.convertByteToData(data))
                            }
                        case "colors":
                            let data = json["data"].stringValue
                            let colors = JSON.init(parseJSON: data)
                            if colors != JSON.null, let dc = colors.dictionaryObject {
                                for (key, value) in dc {
                                    Amytis.colors[key] = value as! String
                                }
                                self.currentController?.__dmReloadDebugViews()
                            }
                        case "language":
                            let data = json["data"].stringValue
                            let langs = JSON.init(parseJSON: data)
                            if langs != JSON.null, let dc = langs.dictionaryObject {
                                for (key, value) in dc {
                                    if let dic = value as? [String: String] {
                                        for (lang, val) in dic {
                                            Amytis.language.set(key: key, lang: lang, value: val)
                                        }
                                    } else if value is String {
                                        Amytis.language.set(key: key, code: Amytis.language.selectedLanguage, value: value as! String)
                                    }
                                }
                                self.currentController?.__dmReloadDebugViews()
                            }
                        default:break;
                        }
                    }
                }
            } catch {
                
            }
        })
        socket?.connect()
    }
    
    func sendToServer(_ event: String, _ msg: Any) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["event": event, "data": msg])
            _ = socket?.send(data: jsonData)
        } catch {
            print("something went wrong with parsing json")
        }
    }
    
    func log(_ data: Any) {
        sendToServer("log", String(describing: data))
        print(data)
    }
    
    
    func sendScreen(_ window: Int = 1, _ quality: Double = 0.1) {
        if let v = UIApplication.shared.keyWindow {
            UIGraphicsBeginImageContextWithOptions(v.frame.size, false, 0);
            v.drawHierarchy(in: CGRect(x: v.frame.origin.x, y: (CGFloat((window - 1) * 2) * v.frame.size.height) + v.frame.origin.y, width: v.frame.size.width, height: v.frame.size.height), afterScreenUpdates: true)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
            let byteArray = (image.jpegData(compressionQuality: CGFloat(quality))?.base64EncodedString(options: .lineLength64Characters))! as String
            self.sendToServer("image", ["image": true, "device_name": UIDevice.current.name, "device_id": UIDevice.current.identifierForVendor!.uuidString, "system_name": UIDevice.current.systemName, "localized_model": UIDevice.current.localizedModel, "buffer": byteArray]);
        }
    }
    
    func requestImage(_ name: String) {
//        sendToServer("requestImage", name);
    }
    
    func addressEdited(_ address: String) {
//        if let url = URL(string: address) {
//            self.initSocket(url: url)
//        }
    }
    
    func handle(text: String) {
        handleCommands(text: text)
        do {
            let doc = try XMLDocument(xml: text)
            if doc.error == nil {
                dm.set(doc)
            }
        } catch {
            loadAdditionsWithText(text)
        }
    }
    
    func handleCommands(text: String) {
        if text == "request" {
            if let txt = UserDefaults.standard.string(forKey: "data") {
//                socket?.emit("request-data", txt.replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "&amp;", with: "&"))
            }
        }
    }
    
    func loadString(_ name: String) -> String? {
        let extensions = ["html", "xml", "amy", "json"]
        for ext in extensions {
            if let path = Bundle.main.path(forResource: name, ofType: ext), let data = NSData(contentsOfFile: path), let str = String(data: data as Data, encoding: .utf8) {
                return str
            }
        }
        return nil
    }
    
    func loadIfNotExist(_ key: String) {
        if xmls[key] == nil, let str = loadString(key) {
            do {
                var txt = str.replacingOccurrences(of: catchPhrases.valueDividerShow, with: catchPhrases.valueDivider)
                if !txt.contains("&amp;") {
                    txt = txt.replacingOccurrences(of: "&", with: "&amp;")
                }
                let xm = try XMLDocument(xml: txt).root
                xmls[key] = xm
                xm.xml(topParams.code) {code in
                    self.codes[key] = code
                }
                xm.xml(topParams.topBar) {tb in
                    self.topBars[key] = tb
                }
            } catch {}
        }
    }
    
    func loadAdditions() {
        if let str = loadString("additions") {
            loadAdditionsWithText(str)
        }
        if let colorsStr = loadString("colors") {
            let colors = JSON.init(parseJSON: colorsStr)
            if colors != JSON.null {
                for (key, value) in colors.dictionaryObject! {
                    Amytis.colors[key] = value as! String
                }
            }
        }
        if let langStr = loadString("language") {
            let langs = JSON.init(parseJSON: langStr)
            if langs != JSON.null {
                for (key, value) in langs.dictionaryObject! {
                    if let dic = value as? [String: String] {
                        for (lang, val) in dic {
                            Amytis.language.set(key: key, lang: lang, value: val)
                        }
                    } else if value is String {
                        Amytis.language.set(key: key, code: Amytis.language.selectedLanguage, value: value as! String)
                    }
                }
            }
        }
    }
    
    func loadAdditionsWithText(_ str: String) {
        do {
            var txt = str.replacingOccurrences(of: catchPhrases.valueDividerShow, with: catchPhrases.valueDivider)
            if !txt.contains("&amp;") {
                txt = txt.replacingOccurrences(of: "&", with: "&amp;")
            }
            txt = "<classes>\(txt)</classes>"
            let xmlss = try XMLDocument(xml: txt).root
            for child in xmlss.children {
                child.string(["name"], {clas in
                    self.xmls[clas] = child
                })
            }
            currentController?.__dmReloadDebugViews()
        } catch {}
    }
    
    func get(_ key: String, paramsS: String? = nil, paramsX: XML? = nil, paramsXAttr: XML? = nil, paramsJ: [String: Any]? = nil,  replaceAttr: [String: String]? = nil, addChildren: [XML]? = nil, str: String? = nil, topBar: Bool = false, code: Bool = false) -> XML? {
        loadIfNotExist(key)
        var xml: XML!
        if topBar {
            xml = topBars[key]
        } else if code {
            xml = codes[key]
        } else {
            xml = xmls[key]
        }
        if xml != nil {
            var val = xml!.xml
            var attrs: [String: String] = [:]
            var strAdded = false
            var childAdded = false
            var childStr: String = ""
            if let childs = addChildren {
                for item in childs {
                    childStr += item.xml
                }
            }
            if let attr = replaceAttr {
                for (key, value) in attr {
                    if val.contains("\(catchPhrases.valueIdentifier)\(key)") {
                        val = val.replacingOccurrences(of: "\(catchPhrases.valueIdentifier)\(key)", with: value)
                    } else if val.contains("\(catchPhrases.valueIdentifier)children"), childStr != "" {
                        childAdded = true
                        val = val.replacingOccurrences(of: "\(catchPhrases.valueIdentifier)children", with: childStr)
                    } else if val.contains("\(catchPhrases.valueIdentifier)value"), let str = str {
                        strAdded = true
                        val = val.replacingOccurrences(of: "\(catchPhrases.valueIdentifier)value", with: str)
                    } else {
                        attrs[key] = value
                    }
                }
            }
            val.params(obj: paramsXAttr, object: paramsX, string: paramsS, dict: paramsJ)
            do {
                xml = try XMLDocument(xml: val).root
            } catch {}
            if !strAdded, let str = str {
                xml?.value = str
            }
            if !childAdded, let childs = addChildren {
                for item in childs {
                    xml?.addChild(item)
                }
            }
            for (key, val) in attrs {
                xml?.attributes[key] = val
            }
        }
        usageCount[key] = getUsageCount(key)
        return xml
    }
    
    func set(_ xmlDoc: XMLDocument) {
        xmlDoc.root.string(viewParams.classs, {classs in
            if let xm = self.xmls[classs] {
                if xm.xml != xmlDoc.root.xml {
                    self.xmls[classs] = xmlDoc.root
                    xmlDoc.root.xml(topParams.code) {code in
                        self.codes[classs] = code
                    }
                    xmlDoc.root.xml(topParams.topBar) {tb in
                        self.topBars[classs] = tb
                    }
                }
            } else {
                self.xmls[classs] = xmlDoc.root
                xmlDoc.root.xml(topParams.code) {code in
                    self.codes[classs] = code
                }
                xmlDoc.root.xml(topParams.topBar) {tb in
                    self.topBars[classs] = tb
                }
            }
            self.reloadView(classs)
            if self.currentController?.amytisControllerName != classs {
                self.currentController?.__dmReloadDebugViews()
            }
        })
        for element in xmlDoc.root.children {
            element.string(viewParams.classs, {classs in
                if let xm = self.xmls[classs] {
                    if xm.xml != element.xml {
                        self.xmls[classs] = element
                        element.xml(topParams.code) {code in
                            self.codes[classs] = code
                        }
                        element.xml(topParams.topBar) {tb in
                            self.topBars[classs] = tb
                        }
                    }
                } else {
                    self.xmls[classs] = element
                    element.xml(topParams.code) {code in
                        self.codes[classs] = code
                    }
                    element.xml(topParams.topBar) {tb in
                        self.topBars[classs] = tb
                    }
                }
                self.reloadView(classs)
                if self.currentController?.amytisControllerName != classs {
                    self.currentController?.__dmReloadDebugViews()
                }
            })
        }
    }
    
    func reloadView(_ id: String) {
        if let view = self.AmytisViews[id] {
            self.runAsync {
                view.__dmReloadDebugViews()
                self.log("###Reloaded : \(view.amytisControllerName)")
            }
        }
    }
    
    func load() {
        loadAdditions()
//        do {
//            if let text = UserDefaults.standard.string(forKey: "data") {
//                let doc = try XMLDocument(xml: text)
//                if doc.error == nil {
//                    self.set(doc)
//                }
//            }
//        }catch{}
    }

    func save() {
        do {
            let xml = try XMLDocument(xml: "<classes/>")
            for (key, x) in xmls {
                //if getUsageCount(key) > 0 {
                x.string(viewParams.classs, {name in
//                    if name != "local" {
                      xml.root.addChild(x)
//                    }
                })
                //}
            }
            UserDefaults.standard.set(xml.xml, forKey: "data")
        }catch{}
    }
    
}


