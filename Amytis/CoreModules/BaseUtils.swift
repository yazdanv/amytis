//
//  AmytisView.swift
//  Pods
//
//  Created by Yazdan on 3/19/17.
//
//

import Foundation


public extension NSObject {
    public func runWD(_ time: Double = 1, _ runable: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: runable)
    }
    public func runAsync(_ runable: @escaping () -> Void) {
        DispatchQueue.main.async(execute: runable)
    }
    public func runBack(_ runable: @escaping () -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: runable)
    }
    public func runBackDip(_ runable: @escaping () -> Void) {
        DispatchQueue.global().async(execute: runable)
    }
    
    public func setNotif(_ name: String, _ selector: Selector) {
        NotificationCenter.default.addObserver(self,selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
    }
    
    public func randomString(withLength length : Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
}


extension XML {
    
    var str: String {
        let val = self.string
        if val.contains("??") {
            let comps = val.components(separatedBy: " ?? ")
            if comps.count > 1 {
                if comps[1].contains(catchPhrases.valueIdentifier2) {
                    return comps[0]
                } else {
                    return comps[1]
                }
            }
        }
        return val
    }
    
    func str(_ keys: [String], _ done: (String) -> Void) {
        for key in keys {
            let element = self[key]
            if element.error != AEXMLError.elementNotFound{
                let val = element.string
                if val.contains("??") {
                    let comps = val.components(separatedBy: " ?? ")
                    if comps.count > 1 {
                        if comps[1].contains(catchPhrases.valueIdentifier2) {
                            done(comps[0])
                        } else {
                            done(comps[1])
                        }
                    }
                } else {
                    done(val)
                }
                break
            }
        }
    }
    
    public func string(_ keys: [String], _ done: (String) -> Void) {
        self.attributes.string(keys, done)
    }
    
    func rawString(_ keys: [String], _ done: (String) -> Void) {
        for key in keys {
            let xml = self[key]
            if xml.error != AEXMLError.elementNotFound {
                done(xml.xml)
                break
            }
        }
    }
    
    public func int(_ keys: [String], _ done: (Int) -> Void) {
        self.string(keys, { (val: String) in
            if let int = Int(val) {
                done(int)
            }
        })
    }
    
    public func double(_ keys: [String], _ done: (Double) -> Void) {
        self.string(keys, { (val: String) in
            if let doub = Double(val) {
                done(doub)
            }
        })
    }
    
    public func float(_ keys: [String], _ done: (Float) -> Void) {
        self.string(keys, { (val: String) in
            if let doub = Float(val) {
                done(doub)
            }
        })
    }
    
    public func bool(_ keys: [String], _ done: (Bool) -> Void) {
        self.string(keys, { (val: String) in
            if val.compare(topParams.yes) {
                done(true)
            } else if val.compare(topParams.no) {
                done(false)
            }
        })
    }
    
    public func yes(_ keys: [String], _ done: () -> Void) {
        self.bool(keys, {if $0 {done()}})
    }
    
    public func True(_ keys: [String], _ done: () -> Void) {
        self.bool(keys, {if $0 {done()}})
    }
    
    public func no(_ keys: [String], _ done: () -> Void) {
        self.bool(keys, {if !$0 {done()}})
    }
    
    public func False(_ keys: [String], _ done: () -> Void) {
        self.bool(keys, {if !$0 {done()}})
    }
    
    public func xml(_ keys: [String], _ done: (XML) -> Void) {
        for key in keys {
            if self[key].error != AEXMLError.elementNotFound {
                done(self[key])
                break
            }
        }
    }
    
    func xmlC(_ keys: [String], _ done: (XML) -> Void) {
        for key in keys {
            if self[key].error != AEXMLError.elementNotFound, self[key].children.count > 0  {
                done(self[key])
                break
            }
        }
    }
    func params(obj: XML? = nil, object: XML? = nil, objects: JSON? = nil, string: String? = nil, dict: [String: Any]? = nil) -> XML? {
        var str = self.xml
        str.params(obj: obj, object: object, objects: objects, string: string, dict: dict)
        do {
            let doc = try XMLDocument(xml: str)
            if doc.error == nil {
                return doc.root
            }
        } catch {}
        return nil
    }
    
}

extension Dictionary where Key == String, Value == String {
    
    func string(_ keys: [String], _ done: (String) -> Void) {
        for key in keys {
            if let val = self[key]{
                if val.contains("??") {
                    let comps = val.components(separatedBy: " ?? ")
                    if comps.count > 1 {
                        if comps[1].contains(catchPhrases.valueIdentifier2) {
                            done(comps[0])
                        } else {
                            done(comps[1])
                        }
                    }
                } else {
                    done(val)
                }
                return
            }
        }
    }
    
}

public extension Dictionary where Key == String, Value == Any {
    public var string: String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
    public var json: JSON {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return try JSON(data: jsonData)
        } catch {
            return JSON.null
        }
    }
}

public extension Array where Element == JSON {
    var dic: [[String: Any]] {
        var arr: [[String: Any]] = []
        for item in self {
            if let i = item.dictionaryObject {
                arr.append(i)
            }
        }
        return arr
    }
}

public extension String {
    
    public var dictionary: [String: Any]? {
        do {
            let decoded = try JSONSerialization.jsonObject(with: self.data(using: .utf8)!, options: [])
            if let dictFromJSON = decoded as? [String: Any] {
                return dictFromJSON
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    public var json: JSON {
        return (try? JSON(data: self.data(using: .utf8)!)) ?? JSON.null
    }
    
    public func compare(_ vals: [String]) -> Bool {
        for val in vals {
            if self == val {return true}
        }
        return false
    }
    
}

extension String {
    
    mutating func params(obj: XML? = nil, object: XML? = nil, objects: JSON? = nil, string: String? = nil, dict: [String: Any]? = nil) {
        var dicc: [String: Any]? = nil
        if let obj = obj {
            for (key,val):(String, String) in obj.attributes {
                let val = self.replacingOccurrences(of: "\(catchPhrases.valueIdentifier)\(key)", with: "\(val)")
                self = val
            }
        } else if let object = object {
            object.xml(viewParams.params, {(xml: XML) in
                for (key,val):(String, String) in xml.attributes {
                    let val = self.replacingOccurrences(of: "\(catchPhrases.valueIdentifier)\(key)", with: "\(val)")
                    self = val
                }
            })
        } else if let object = objects {
            if let dic = object.dictionaryObject {
                dicc = dic
            }
        } else if let dict = dict {
            dicc = dict
        } else if let string = string {
            var vl = self
            let vals = string.components(separatedBy: cp.listDivider)
            let replace = {(val :String) in
                let components = val.components(separatedBy: cp.valueDivider)
                if components.count > 1 {
                    vl = vl.replacingOccurrences(of: "\(catchPhrases.valueIdentifier)\(components[0])", with: "\(components[1])")
                }
            }
            if vals.count > 1 {
                for val in vals {
                    replace(val)
                }
            } else {
                replace(string)
            }
            self = vl
        }
    if let dic = dicc {
        for (key,val):(String, Any) in dic {
            if let val = val as? String {
                let val = self.replacingOccurrences(of: "\(catchPhrases.valueIdentifier)\(key)", with: "\(val)")
                self = val
            } else if let val = val as? JSON {
                if let dic = val.dictionaryObject {
                    for (key2,val2):(String, Any) in dic {
                        let val = self.replacingOccurrences(of: "\(catchPhrases.valueIdentifier)\(key)-\(key2)", with: "\(val2)")
                        self = val
                    }
                }
            } else if let vals = val as? [Any] {
                var i = 0
                for val in vals {
                    if let dic = val as? [String: Any] {
                        for (key2,val2):(String, Any) in dic {
                            let (first, second) = ("\(catchPhrases.valueIdentifier)\(key)-\(i)-\(key2)", "\(val2)")
                            let val = self.replacingOccurrences(of: first, with: second)
                            self = val
                        }
                    } else {
                        let val = self.replacingOccurrences(of: "\(catchPhrases.valueIdentifier)\(key)-\(i)", with: "\(val)")
                        self = val
                    }
                    i += 1
                }
            }
        }
        }
    }
    
}

extension AmytisView {
    func loadFromUD(key: String, paramsX: XML? = nil, paramsJ: XML? = nil, paramsS: String? = nil) -> String?{
        if let str = UserDefaults.standard.string(forKey: key) {
            var st = str
            st.params(obj: paramsX, object: paramsJ, string: paramsS)
            return st
        }
        return nil
    }
}
