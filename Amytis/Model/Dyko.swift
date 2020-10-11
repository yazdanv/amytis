//
//  Dyko.swift
//  Pods
//
//  Created by Yazdan on 5/11/17.
//
//

import Foundation
import JavaScriptCore

let key = "2f225960-8730-4ce8-ae79-aabbdf0bcc7a"
let iv = "a95bd150-8bc6-4d18-bd4c-d674cc42af47"


@objc public protocol JSDykoProtocol: JSExport {
    static func open(_ name: String) -> Dyko
    func collection(_ name: String) -> DykoFile?
}

public class Dyko: NSObject, JSDykoProtocol {
    
    var folder: String = ""
    
    init(_ name: String) {
        super.init()
        folder = name
    }
    
    func openFile(_ file: String) -> URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            try? FileManager.default.createDirectory(at: dir.appendingPathComponent("Dyko/\(folder)/", isDirectory: true), withIntermediateDirectories: true)
            return dir.appendingPathComponent("Dyko/\(folder)/\(file)")
        }
        return nil
    }
    
    public func collection(_ name: String) -> DykoFile? {
        if let file = openFile("\(name).json") {
            return DykoFile(file)
        }
        return nil
    }
    
    public class func open(_ name: String) -> Dyko {
        if name != "Amytis" {
            return Dyko(name)
        } else {
            return Dyko("Default")
        }
    }
    
}



//MARK: DykoFile

@objc public protocol JSDykoFileProtocol: JSExport {
    func insert(_ json: [String: Any], _ callback: JSValue)
    func byId(_ id: Int, _ callback: JSValue)
    func modify(_ id: Int, _ data: [String: Any], _ callback: JSValue)
    func modifyQuery(_ query: [String: Any], _ data: [String: Any], _ callback: JSValue)
    func find(_ query: [String: Any], _ callback: JSValue)
    func all(_ callback: JSValue)
    func delete(_ id: String)
    func commit()
}

public class DykoFile: NSObject, JSDykoFileProtocol {
    
    var path: URL!
    var file: JSON?
    
    private var firstId: String?
    
    init(_ path: URL) {
        super.init()
        self.path = path
        do {
            if let data = readFile().data(using: .utf8) {
                let jsn = try JSON(data: data)
                if jsn != JSON.null {
                    file = jsn
                    if let i = self.firstId {self.delete(i)}
                }
            }
        } catch {
            print("Error Parsing Database Documents")
        }
    }
    
    func randomID() -> (String, Int) {
        func randomString(_ length: Int) -> String {
            
            let letters : NSString = "0123456789"
            let len = UInt32(letters.length)
            
            var randomString = ""
            
            for _ in 0 ..< length {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            
            return randomString
        }
        let date = Date()
        let c = Calendar.init(identifier: .gregorian)
//        var year = "\(c.component(.year, from: date))"
//        year.removeFirst()
//        year.removeFirst()
//        let month = c.component(.month, from: date);
//        let day = c.component(.day, from: date);
//        let hour = c.component(.hour, from: date);
//        let minute = c.component(.minute, from: date);
//        let second = c.component(.second, from: date);
        let nanoSecond = c.component(.nanosecond, from: date)
//        let ss = "\(year)\(month < 10 ? "0\(month)":"\(month)")\(day < 10 ? "0\(day)":"\(day)")\(hour < 10 ? "0\(hour)":"\(hour)")\(minute < 10 ? "0\(minute)":"\(minute)")\(second < 10 ? "0\(second)":"\(second)")"
        let str = "\(nanoSecond)\(arc4random_uniform(4))".replacingOccurrences(of: ".", with: "")
        if let int = Int(str) {
            return (str, int)
        }
        return("0",0)
    }
    
    func readFile() -> String {
        do {
            let s = try String(contentsOf: path)
            let dec = try s.aesDecrypt(key: key, iv: iv)
            return dec
        }
        catch {
            let (id, _) = randomID()
            firstId = id
            return "{\"\(id)\": {\"start\": \"index\"}}"
        }
    }
    
    func writeFile(_ tried: Int) {
        do {
            if let file = file, let str = file.rawString() {
                let enc = str.aesEncrypt(key: key, iv: iv).data(using: .utf8)
                try enc!.write(to: path, options: .atomic)
            }
        } catch {
            if tried < 2 {
                writeFile(tried+1)
            }
        }
    }
    
    public func insert(data: [String: Any], action: ((Int) -> Void)) {
        if file != nil {
            var jsn = data
            let (sId, id) = randomID()
            jsn["_id"] = id
            file![sId].dictionaryObject = jsn
            action(id)
        }
    }
    
    public func byId(id: Int, action: (([String: Any]) -> Void)) {
        if let file = file {
            let json = file["\(id)"]
            if json != JSON.null {
                action(json.dictionaryObject!)
            }
        }
    }
    
    public func modify(id: Int, data: [String: Any]) {
        if let file = file {
            let json = file["\(id)"]
            if json != JSON.null {
                var jsn = json.dictionaryObject!
                for (key, val) in data {
                    if key != "_id" {
                        jsn[key] = val
                    }
                }
                self.file!["\(id)"].dictionaryObject = jsn
            }
        }
    }
    
    public func modify(id: Int, data: [String: Any], action: ((Bool) -> Void)) {
        byId(id: id, action: {
            var jsn = $0
            for (key, val) in data {
                if key != "_id" {
                    jsn[key] = val
                }
            }
            if let _id = jsn["_id"] as? Int {
                self.file!["\(_id)"].dictionaryObject = jsn
                action(true)
            } else {
                action(false)
            }
        })
    }
    
    public func modify(query: [String: Any], data: [String: Any], action: @escaping ((Bool) -> Void)) {
        find(query: query, action: {
            for item in $0 {
                var jsn = item
                for (key, val) in data {
                    if key != "_id" {
                        jsn[key] = val
                    }
                }
                if let _id = jsn["_id"] as? Int {
                    self.file!["\(_id)"].dictionaryObject = jsn
                }
            }
            action(true)
        })
    }
    
    public func find(query: [String: Any], action: @escaping (([[String: Any]]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
        if let file = self.file {
            var result: [[String: Any]] = []
            var qString: [String: String] = [:]
            var qBool: [String: Bool] = [:]
            var qCount = 0
            for (key, val) in query {
                qCount += 1
                if let val = val as? Bool {
                    qBool[key] = val
                } else {
                    qString[key] = "\(val)"
                }
            }
            for (_, json) in file {
                var match = 0
                for (qKey, qVal) in qString {
                    if let data = json[qKey].string {
                        if data == qVal {
                            match += 1
                        }
                    } else if let data = json[qKey].int {
                        if let int = Int(qVal) {
                            if data == int {
                                match += 1
                            }
                        }
                    } else if let data = json[qKey].double {
                        if let double = Double(qVal) {
                            if data == double {
                                match += 1
                            }
                        }
                    }
                }
                for (qKey, qVal) in qBool {
                    if let data = json[qKey].bool {
                        if data == qVal {
                            match += 1
                        }
                    }
                }
                if match == qCount {
                    result.append(json.dictionaryObject!)
                }
            }
            self.runAsync {action(result)}
        }
        }
    }
    
    public func all(action: (([[String: Any]]) -> Void)) {
        if let file = self.file {
            var arr: [[String: Any]] = []
            for (_ , val) in file.dictionaryValue {
                arr.append(val.dictionaryObject!)
            }
            action(arr)
        } else {
            action([])
        }
    }
    
    public func delete(_ id: String) {
        if file != nil {
            file!.dictionaryObject?.removeValue(forKey: id)
        }
    }
    
    public func commit() {
        writeFile(0)
    }
    
    
    /////////////////////// js wrappers
    
    
    public func insert(_ json: [String: Any], _ callback: JSValue) {
        insert(data: json, action: {callback.call(withArguments: [$0])})
    }
    public func byId(_ id: Int, _ callback: JSValue) {
        byId(id: id, action: {callback.call(withArguments: [$0])})
    }
    public func modify(_ id: Int, _ data: [String: Any], _ callback: JSValue) {
        modify(id: id, data: data, action: {callback.call(withArguments: [$0])})
    }
    public func modifyQuery(_ query: [String: Any], _ data: [String: Any], _ callback: JSValue) {
        modify(query: query, data: data, action: {callback.call(withArguments: [$0])})
    }
    public func find(_ query: [String: Any], _ callback: JSValue) {
        find(query: query, action: {callback.call(withArguments: [$0])})
    }
    public func all(_ callback: JSValue) {
        all(action: {arr in callback.call(withArguments: [arr])})
    }
}


extension String {
    func aesEncrypt(key: String, iv: String) -> String {
//        let data = self.data(using: .utf8)!
//        let encrypted = try! AES(key: key.data(using: .utf8)!.bytes, blockMode: .CBC(iv: iv.data(using: .utf8)!.bytes), padding: .pkcs7).encrypt([UInt8](data))
//        let encryptedData = Data(encrypted)
//        return encryptedData.base64EncodedString()
        return self
    }
    
    func aesDecrypt(key: String, iv: String) -> String {
//        let data = Data(base64Encoded: self)!
//        let decrypted = try! AES(key: key.data(using: .utf8)!.bytes, blockMode: .CBC(iv: iv.data(using: .utf8)!.bytes), padding: .pkcs7).decrypt([UInt8](data))
//        let decryptedData = Data(decrypted)
//        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
        return self
    }
}
