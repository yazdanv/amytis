//
//  UIColor.swift
//  Pods
//
//  Created by Yazdan on 3/19/17.
//
//

import UIKit

extension UIColor {
    static func fromHex(_ hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) == 8) {
            let color = cString.substring(from: cString.index(cString.startIndex, offsetBy: 2))
            let alpha = cString.substring(to: cString.index(cString.startIndex, offsetBy: 2))
            var rgbValue:UInt32 = 0
            Scanner(string: color).scanHexInt32(&rgbValue)
            var alphaValue:UInt32 = 0
            Scanner(string: alpha).scanHexInt32(&alphaValue)
            let (r, g, b, a) = ((CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0), (CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0), (CGFloat(rgbValue & 0x0000FF) / 255.0), (CGFloat(alphaValue)/255.0))
            return UIColor(red: r, green: g, blue: b, alpha: a)
        } else if ((cString.characters.count) != 6) {
            return UIColor.clear
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    public static func pickColor(_ colorName: String) -> UIColor {
        if colorName == "clear" {
            return UIColor.clear
        } else if colorName == "group" {
            return UIColor.groupTableViewBackground
        }
        var colors: [String: String]? = ["red": "f44336", "pink": "e91e63", "purple": "9c27b0", "indigo": "3f51b5", "blue": "2196f3", "cyan": "00bcd4", "teal": "009688", "green": "4caf50", "lime": "cddc39", "yellow": "ffeb3b", "amber": "ffc107", "orange": "ff9800", "brown": "795548", "grey": "9e9e9e", "black": "000000", "white": "ffffff"]
        if let color = colors?[colorName.lowercased()]{
            colors = nil
            return UIColor.fromHex(color)
        } else if let color = Amytis.colors[colorName] {
            colors = nil
            return UIColor.fromHex(color)
        } else {
            colors = nil
            return UIColor.fromHex(colorName)
        }
    }
    
    public static var randomDark: UIColor {
        let colors: [String] = ["b71c1c", "880E4F", "4A148C", "311B92", "1A237E", "0D47A1", "01579B", "006064", "004D40", "1B5E20", "33691E", "827717", "F57F17", "FF6F00", "E65100", "BF360C", "3E2723", "212121", "263238"]
        return UIColor.fromHex(colors[Int(arc4random_uniform(UInt32(colors.count)))])
    }
//    static var randomLight: UIColor {
//
//    }
    
}
