//
//  Constraints.swift
//  Alamofire
//
//  Created by Yazdan on 6/16/17.
//

//import Foundation
//import UIKit
//
//class Constrains: NSObject {
//    
//    var visualConstraints: [String] = []
//    var parent: AmytisView!
//    
//    convenience init(_ parent: AmytisView, _ object: XML) {
//        self.init()
//        self.parent = parent
//        if let visuals = object["visual"].all {
//            for visual in visuals {
//                self.visualConstraints.append(visual.str)
//            }
//        }
//    }
//    
//    func activateConstraints() {
//        runAsync {
//            for formatString in self.visualConstraints {
//                var views: [String: Any] = [:]
//                for (id, view) in self.parent.views {
//                    if formatString.contains(id) {
//                        views[id] = view
//                    }
//                }
//                let constraints = NSLayoutConstraint.constraints(withVisualFormat: formatString, options: .alignAllTop, metrics: nil, views: views)
//                NSLayoutConstraint.activate(constraints)
//            }
//        }
//    }
//    
//}

