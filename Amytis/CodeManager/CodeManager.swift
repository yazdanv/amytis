//
//  CodeManager.swift
//  Alamofire
//
//  Created by Yazdan Vakili on 11/26/17.
//

///// developing as replacement for DataManager

import Foundation

let CM = CodeManager()

class CodeManager: NSObject {
    
    /////////////// db refrences
    var db: Dyko!
    var vColl: DykoFile!
    var cColl: DykoFile!
    var pColl: DykoFile!
    
    ///////////// in memory store
    var views: [String: XML] = [:]
    var codes: [String: XML] = [:]
    var topBars: [String: XML] = [:]
    var colors: [String: Any] = [:]
    var params: [String: Any] = [:]
    
    
    
    override init() {
        super.init()
        db = Dyko("Amytis")
        vColl = db.collection("vColl")
        cColl = db.collection("cColl")
        pColl = db.collection("pColl")
    }
    
}
