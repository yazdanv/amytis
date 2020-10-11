//
//  JSValue+Extension.swift
//  Amytis
//
//  Created by Yazdan Vakili on 4/25/18.
//

import Foundation
import JavaScriptCore


extension JSValue {
    func any(_ name: String) -> Any? {
        if let a = self.forProperty(name), !a.isUndefined {
            return a.toObject()
        }
        return nil
    }
    func string(_ name: String) -> String? {
        if let s = self.forProperty(name), !s.isUndefined {
            return s.toString()
        }
        return nil
    }
    func closure(_ name: String) -> (() -> Void)? {
        if let c = self.forProperty(name), !c.isUndefined {
            return {c.call(withArguments: [])}
        }
        return nil
    }
    func value(_ name: String) -> JSValue? {
        if let v = self.forProperty(name), !v.isUndefined {
            return v
        }
        return nil
    }
    func dic(_ name: String) -> [String: Any]? {
        if let d = self.forProperty(name), !d.isUndefined {
            return d.toObject() as? [String: Any]
        }
        return nil
    }
    func dicString(_ name: String) -> [String: String]? {
        if let d = self.forProperty(name), !d.isUndefined {
            return d.toObject() as? [String: String]
        }
        return nil
    }
    func int(_ name: String) -> Int? {
        if let i = self.forProperty(name), !i.isUndefined {
            return Int(i.toInt32())
        }
        return nil
    }
    func double(_ name: String) -> Double? {
        if let d = self.forProperty(name), !d.isUndefined {
            return d.toDouble()
        }
        return nil
    }
}
