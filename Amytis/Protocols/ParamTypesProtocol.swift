//
//  ParamTypesProtocol.swift
//  Alamofire
//
//  Created by Yazdan Vakili on 11/17/17.
//

import Foundation
import JavaScriptCore

@objc public protocol ParamTypesProtocol: JSExport {
    var params: [String: Any] {get set}
}

public class ParamType {
    
    let value: Any?
    let action: ((Any) -> Void)
    
    init (value: Any?, action: @escaping ((Any?) -> Void)) {
        self.value = value
        self.action = action
    }
    
    public var int: Int? {
        set {
            action(newValue as Any)
        }
        get {
            if let val = value as? Int {
                return val
            }
            return nil
        }
    }
    
    public var str: String? {
        set {
            action(newValue as Any)
        }
        get {
            if let val = value as? String {
                return val
            }
            return nil
        }
    }
    
    public var string: String? {set {str=newValue} get {return str}}
    
    public var double: Double? {
        set {
            action(newValue as Any)
        }
        get {
            if let val = value as? Double {
                return val
            }
            return nil
        }
    }
    
}

public extension ParamTypesProtocol {
    public func v(_ name: String) -> ParamType {return ParamType(value: params[name], action: {self.params[name] = $0})}
}
