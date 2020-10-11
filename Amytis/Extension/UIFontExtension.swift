//
//  UIFont+Extension.swift
//  Alamofire
//
//  Created by Yazdan on 10/31/17.
//

import UIKit

extension UIFont {
    
    static func flexFont(_ font: UIFont, _ str: String) -> UIFont {
        let screenSize = UIScreen.main.bounds
        let size: CGFloat = (screenSize.width + screenSize.height)/2
        if let s = Double(str.replacingOccurrences(of: "f", with: "")) {
            return font.withSize(size * (CGFloat(s) * 0.005))
        }
        return font
    }
    
}
