//
//  RequestHandler.swift
//  Alamofire
//
//  Created by Yazdan on 7/9/17.
//

import Foundation
import JavaScriptCore

public let RH = RequestHandler()
public let Request = RH

public enum DataCoding: Int {
    case json = 1
    case formdata = 2
    case urlEncoded = 3
}

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

@objc public protocol RequestHandlerJSWrapper: JSExport {
    func JsRequest(_ url: String, _ method: String, _ params: JSValue)
}

public class RequestHandler: NSObject, RequestHandlerJSWrapper {
    
    public func json(_ url: String, _ parameters: [String: Any] = [:], headers: [String: String] = [:], method: RequestMethod = .get, coding: DataCoding = .urlEncoded, retry: Int = 1, _tried: Int = 0, object: ((JSON) -> Void)? = nil, array: (([JSON]) -> Void)? = nil, string: ((String) -> Void)? = nil, failure: (() -> Void)? = nil) {
        var tried = _tried;
        let failed = {
            if tried < retry {
                self.json(url, parameters, method: method, coding: coding, retry: retry,  _tried: tried, object: object, array: array, failure: failure)
            } else {
                if let failure = failure {failure()}
            }
        }
        tried += 1
        let handleData = {(val: String) in
            print(val)
            do {
                let jsn = try JSON(data: val.data(using: .utf8)!)
                if let json = jsn.array {
                    if let array = array {
                        array(json)
                    }
                } else if jsn != JSON.null  {
                    if let object = object {
                        object(jsn)
                    }
                } else {
                    string?(val)
                }
            } catch {failed()}
        }
        if method != .get {
            self.postStr(url, parameters, headers: headers, method: method, coding: coding, success: handleData, failed: failed)
        } else {
            self.getStr(url, parameters, headers: headers, success: handleData, failed: failed)
        }
    }
    
    public func getStr(_ url: String, _ parameters: [String: Any] = [:], headers: [String: String] = [:], success: @escaping ((String) -> Void), failed: (() -> Void)? = nil) {
        get(url, parameters, success: {dt in if let str = String(data: dt, encoding: .utf8) {success(str)} else {failed?()}}, failed: failed)
    }
    
    public func get(_ url: String, _ parameters0: [String: Any] = [:], headers: [String: String] = [:], success: @escaping ((Data) -> Void), failed: (() -> Void)? = nil) {
        var paramStr = ""
        var parameters = parameters0
        var first = true
        for (key, value) in parameters {
            if let val = value as? Bool {
                parameters[key] = val ? "true":"false"
            }
        }
        for (key, value) in parameters {
            if first {
                paramStr += "?\(key)=\(value)"
                first = false
            } else {
                paramStr += "&\(key)=\(value)"
            }
        }
        if let url = URL(string: "\(url)\(paramStr)") {
            var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 15)
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let dt = data {
                    DispatchQueue.main.async {success(dt)}
                } else {
                    DispatchQueue.main.async {failed?()}
                }
                }.resume()
        }
    }
    
    public func postStr(_ url: String, _ parameters: [String: Any] = [:], headers: [String: String] = [:], method: RequestMethod = .post, coding: DataCoding = .json, success: @escaping ((String) -> Void), failed: (() -> Void)? = nil) {
        post(url, parameters, headers: headers, method: method, coding: coding, success: {dt in if let str = String(data: dt, encoding: .utf8) {success(str)} else {failed?()}}, failed: failed)
    }
    
    public func post(_ url: String, _ parameters0: [String: Any] = [:], headers: [String: String] = [:], method: RequestMethod = .post, coding: DataCoding = .json, success: @escaping ((Data) -> Void), failed: (() -> Void)? = nil) {
        if let url = URL(string: url) {
            var parameters = parameters0
            for (key, value) in parameters {
                if let val = value as? Bool {
                    parameters[key] = val ? "true":"false"
                }
            }
            var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 15)
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
            let requestMethod = method.rawValue
            request.httpMethod = requestMethod
            if parameters.keys.count > 0 {
                switch coding {
                case .formdata:
                    var data = ""
                    for (key, value) in parameters {data+="\(key):\(value)\n"}
                    request.httpBody = data.data(using: .utf8)
                case .urlEncoded:
                    var data = ""
                    for (key, value) in parameters {data+="\(key)=\(value)&"}
                    data.characters.removeLast()
                    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.httpBody = data.data(using: .utf8)
                default:
                    let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = jsonData
                }
            }
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let dt = data {
                    DispatchQueue.main.async {success(dt)}
                } else {
                    print(error)
                    DispatchQueue.main.async {failed?()}
                }
            }.resume()
        }
    }
    
    public func JsRequest(_ url: String, _ method: String, _ params: JSValue) {
        var parameters: [String: Any] = [:]
        if let p = params.dic("parameters") {parameters = p}
        var headers: [String: String] = [:]
        if let h = params.dicString("headers") {headers = h}
        var coding: DataCoding = .urlEncoded
        if let c = params.string("coding") {
            if c == "json" {
                coding = .json
            } else if c == "form" {
                coding = .formdata
            }
        }
        var failed: (() -> Void)? = nil
        if let fail = params.value("failed") {failed = {fail.call(withArguments: [])}}
        var comp: ((String) -> Void)? = nil
        if let c = params.value("completion") {comp = {str in c.call(withArguments: [str])}}
        var object: ((JSON) -> Void)? = nil
        var array: (([JSON]) -> Void)? = nil
        if let obj = params.value("json") {object = {jsn in obj.call(withArguments: [jsn.dictionaryObject!])}}
        if let arr = params.value("array") {array = {jArr in
            var jsonArray: [[String: Any]] = []
            jArr.forEach {jsonArray.append($0.dictionaryObject ?? [:])}
            arr.call(withArguments: [jsonArray])
        }}
        self.json(url, parameters, headers: headers, method: method == "post" ? .post:.get, coding: coding, retry: 25, _tried: 0, object: object, array: array, string: comp, failure: failed)
    }
    
}
