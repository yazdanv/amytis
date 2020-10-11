//
//  ExtendableView.swift
//  Alamofire
//
//  Created by Yazdan on 8/3/17.
//

import Foundation

public protocol ExtendableView: ParamTypesProtocol {
    var params: [String: Any] {get set}
//    var delegate: ExtendableViewDelegate {get set}
}

public protocol ExtendableViewDelegate {
    func onCreate(object: XML)
}
