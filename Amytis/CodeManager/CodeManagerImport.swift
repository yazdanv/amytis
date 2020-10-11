//
//  CodeManagerImport.swift
//  Alamofire
//
//  Created by Yazdan Vakili on 11/26/17.
//

import Foundation

extension CodeManager {
    
    func loadFile(name: String, extensions: [String] = ["amy", "xml", "html"], date: String) -> String? {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if let urlArray = try? FileManager.default.contentsOfDirectory(at: directory,
                                                                       includingPropertiesForKeys: [.contentModificationDateKey],
                                                                       options:.skipsHiddenFiles) {
            for url in urlArray {
                let path = url.lastPathComponent
                let fDate = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                if path.contains(only: name), let lst = path.components(separatedBy: ".").last, extensions.contains(lst), let nDate = DateFormatter().date(from: date), fDate.isGreaterThanDate(dateToCompare: nDate) {
                    return try? String(contentsOf: url)
                }
            }
        } else {
            return nil
        }
        return nil
    }
    
    func importAllFromDB() {
        vColl.all {
            for item in $0 {
                if let c = item["class"] as? String, let v = item["xml"] as? String, let editDate = item["edit"] as? String {
                    if let file = loadFile(name: c, date: editDate) {
                        
                    } else {
                        
                    }
                }
            }
        }
    }
    
    func importXML(fromString str: String) {
        
    }
}
