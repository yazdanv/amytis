//
//  Language.swift
//  Alamofire
//
//  Created by Yazdan on 6/14/17.
//

import Foundation
import UIKit

public enum languageCodes: String {
    case english = "en"
    case persian = "fa"
    case spanish = "sp"
    case french = "fr"
    case arabic = "ar"
}

public class Language: NSObject {
    
    var selectedLanguage: languageCodes = .english
    
    var defaultLanguageKeys: [languageCodes: [String: String]] = [:]
    
    var languageFont: [languageCodes: String] = [:]
    
    public var isRtl: Bool {
        let langDirection: [languageCodes: Bool] = [.persian: true, .arabic: true]
        if let rtl = langDirection[selectedLanguage] {
            return rtl
        } else {
            return false
        }
    }
    
    public var isDefault: Bool {
        if let code = UserDefaults.standard.string(forKey: "AmytisSelectedLanguageCode"), languageCodes(rawValue: code) != nil {
            return false
        } else {
            return true
        }
    }
    
    public var name: String {
        let list: [languageCodes: String] = [.persian: "فارسی", .english: "English"]
        return list[selectedLanguage]!
    }
    
    public func selectLanguage(_ lang: languageCodes) {
        let code = lang.rawValue
        UserDefaults.standard.set(code, forKey: "AmytisSelectedLanguageCode")
        setLang(lang)
    }
    
    public func get(_ key: String, _ action: (String) -> Void) {
        if let val = defaultLanguageKeys[selectedLanguage]?[key] {
            action(val)
        }
    }
    
    public func get(_ key: String) -> String? {
        if let val = defaultLanguageKeys[selectedLanguage]?[key] {
            return val
        }
        return nil
    }
    
    public func set(key: String, code: languageCodes, value: String) {
        if defaultLanguageKeys[code] != nil {
            defaultLanguageKeys[code]![key] = value
        } else {
            defaultLanguageKeys[code] = [:]
            defaultLanguageKeys[code]![key] = value
        }
    }
    
    public func set(key: String, lang: String, value: String) {
        if let code = languageCodes.init(rawValue: lang) {
            set(key: key, code: code, value: value)
        }
    }
    
    public func langFont(size: CGFloat = UIFont.systemFontSize) -> UIFont? {
        if let fnt = languageFont[selectedLanguage], let fn = UIFont(name: fnt, size: size) {
            return fn
        }
        return nil
    }
    
    public func setDefault(defaultLanguage: languageCodes, keys: [String: [languageCodes: String]], fonts: [languageCodes: String] = [:]) {
        setLang(defaultLanguage)
        setKeys(keys: keys)
        self.languageFont = fonts
    }
    
    func setKeys(keys: [String: [languageCodes: String]]) {
        for (key, val) in keys {
            for (code, value) in val {
                if defaultLanguageKeys[code] != nil {
                    defaultLanguageKeys[code]![key] = value
                } else {
                    defaultLanguageKeys[code] = [:]
                    defaultLanguageKeys[code]![key] = value
                }
            }
        }
    }
        
    public func setLang(_ lang: languageCodes) {
        
        if let code = UserDefaults.standard.string(forKey: "AmytisSelectedLanguageCode"), let lng = languageCodes(rawValue: code) {
            self.selectedLanguage = lng
        } else {
            self.selectedLanguage = lang
        }
    }
    
}

public struct languageKeys {
    public static let imageLocation = "image_location"
    public static let photoLibrary = "photo_library"
    public static let camera = "camera"
    public static let fromLibraryOrCamera = "from_library_or_camera"
    public static let okAlertButton = "ok_alert_button"
    public static let cancelAlertButton = "cancel_alert_button"
    public static let didGetMemoryWarning = "did_get_memory_warning"
}

public extension String {
    var local: String {
        if let l = Amytis.language.get(self) {
            return l
        } else {
            return self
        }
    }
    var localized: String {
        if let l = Amytis.language.get(self) {
            return l
        } else {
            return self
        }
    }
}
