//
//  String+Extension.swift
//  Alamofire
//
//  Created by Yazdan on 10/31/17.
//

import Foundation


public extension String {
    
    public var attributedWithLangFont: NSMutableAttributedString {
        var str = NSMutableAttributedString(string: self)
        if let font = Amytis.language.langFont() {
            str = NSMutableAttributedString(string: self, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
        }
        return str
    }
    public func attributedWithLangFont(_ size: CGFloat) -> NSMutableAttributedString {
        var str = NSMutableAttributedString(string: self)
        if let font = Amytis.language.langFont(size: size) {
            str = NSMutableAttributedString(string: self, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
        }
        return str
    }
    
    public var camelCased: String {
        if self.count > 0 {
            let source = self.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
            if source.contains(" ") {
                let first = (source as NSString).lowercased.substring(to: source.index(after: source.startIndex))
                let cammel = source.capitalized.replacingOccurrences(of: " ", with: "")
                let rest = cammel.dropFirst()
                return "\(first)\(rest)"
            } else {
                let first = (source as NSString).lowercased.substring(to: source.index(after: source.startIndex))
                let rest = source.dropFirst()
                return "\(first)\(rest)"
            }
        }
        return self
    }
    
    public var CamelCased: String {
        if self.count > 0 {
            let source = self.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
            if source.contains(" ") {
                let cammel = source.capitalized.replacingOccurrences(of: " ", with: "")
                return cammel
            } else {
                let first = (source as NSString).lowercased.substring(to: source.index(after: source.startIndex))
                let rest = source.dropFirst()
                return "\(first.uppercased())\(rest)"
            }
        }
        return self
    }
    
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
