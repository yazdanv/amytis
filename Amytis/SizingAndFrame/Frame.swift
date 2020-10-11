//
//  Position.swift
//  AmytisViews
//
//  Created by Yazdan on 3/16/17.
//  Copyright © 2017 Yazdan. All rights reserved.
//

import Foundation


public class Frame: NSObject {
    
    var origin: CGPoint!
    var size: CGSize!
    var rect: CGRect {
        return CGRect(origin: origin, size: size)
    }
    var parent: UIView!
    var object: XML!
    var rotate: (() -> Void)?
    
    init(_ object: XML, _ parent: UIView, _ origin: CGPoint, _ size: CGSize) {
        super.init()
        self.origin = origin
        self.size = size
        self.object = object
        self.parent = parent
//        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sizeChanged), name: NSNotification.Name.init("sizeChanged"), object: nil)
    }
    
    deinit {
        origin = nil
        size = nil
        parent = nil
        object = nil
        rotate = nil
    }
    
    func empty() {
        origin = nil
        size = nil
        parent = nil
        object = nil
        rotate = nil
    }
    
    @objc func sizeChanged() {
        if let rot = self.rotate {
            let (origin, size) = Frame.config(from: self.object, withParent: self.parent)
            if let size = size, let origin = origin {
                (self.size, self.origin) = (size, origin)
            }
            rot()
        }
    }
    
    func rotated() {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
            if let rot = self.rotate, !(self.size.width == 0 && self.size.height == 0)  {
                let (origin, size) = Frame.config(from: self.object, withParent: self.parent)
                if let size = size, let origin = origin {
                    (self.size, self.origin) = (size, origin)
                }
                UIView.animate(withDuration: 0.2, animations: {rot()})
            }
//        })
    }
    
    static func create(from object: XML, withParent parent: UIView, Aview aview: AmytisView? = nil) -> Frame {
        let (origin, size) = Frame.config(from: object, withParent: parent, Aview: aview)
        if let size = size, let origin = origin {
            return Frame(object, parent, origin, size)
        } else {
            return Frame(object, parent, CGPoint(x: 0, y: 0), CGSize(width: 0, height: 0))
        }
    }
    
    static func config(from object: XML, withParent parent: UIView, Aview aview: AmytisView? = nil) -> (CGPoint?, CGSize?){
        var detectedSize: CGSize = CGSize.zero
        var detectedOrigin: CGPoint = CGPoint.zero

        object.string(vp.frame, {(frm: String) in
            var (x, y) = ("", "")
            var frame = frm
            let parts = frame.components(separatedBy: catchPhrases.partsDivider)
            if parts.count == 2 {
                for part in parts {
                    let parts2 = part.components(separatedBy: catchPhrases.valueDivider)
                    if parts2.count == 2 {
                        if parts2[0].lowercased().compare(viewParams.iphone), UIDevice.current.userInterfaceIdiom == .phone {
                            frame = parts2[1]
                        } else if parts2[0].lowercased().compare(viewParams.ipad), UIDevice.current.userInterfaceIdiom == .pad {
                            frame = parts2[1]
                        }
                    }
                }
            } else if parts.count > 2 {
                for part in parts {
                    let parts2 = part.components(separatedBy: catchPhrases.valueDivider)
                    if parts2.count == 2 {
                        if parts2[0].lowercased().compare(viewParams.iphone), UIDevice.current.userInterfaceIdiom == .phone {
                            frame = parts2[1]
                        } else if parts2[0].lowercased().compare(viewParams.ipad), UIDevice.current.userInterfaceIdiom == .pad {
                            frame = parts2[1]
                        }
                    }
                }
            }
            var comps = frame.components(separatedBy: cp.sizeDivider)
            if frame.contains(",") {
                let comps = Frame.replaceRect(frm, CGRect(origin: detectedOrigin, size: detectedSize), parent.frame, parentAView: aview).components(separatedBy: ",")
                if comps.count > 3, let x = Int(comps[0]), let y = Int(comps[1]), let width = Int(comps[2]), let height = Int(comps[3]) {
                    detectedOrigin = CGPoint(x: x, y: y)
                    detectedSize = CGSize(width: width, height: height)
                }
            } else if frame == "full" {
                (detectedOrigin, detectedSize) =  (CGPoint.zero, parent.frame.size)
            } else {
                if comps.count > 1 {
                    if comps[0] == "full" {
                        var (mLeft, mRight, mTop, mBottom) = (0,0,0,0)
                        if let margin = Int(comps[1]) {
                            (mLeft, mRight, mTop, mBottom) = (margin,margin,margin,margin)
                        } else if comps[1].contains("(") {
                            comps[1] = comps[1].replacingOccurrences(of: "(", with: "")
                            comps[1] = comps[1].replacingOccurrences(of: ")", with: "")
                            let compss = comps[1].components(separatedBy: ",")
                            if compss.count == 2 {
                                if let m1 = Int(compss[0]), let m2 = Int(compss[1]) {
                                   (mLeft, mRight, mTop, mBottom) = (m1,m1,m2,m2)
                                }
                            } else if compss.count == 4 {
                                if let m1 = Int(compss[0]), let m2 = Int(compss[1]), let m3 = Int(compss[2]), let m4 = Int(compss[3]) {
                                    (mTop, mRight, mBottom, mLeft) = (m1,m2,m3,m4)
                                }
                            }
                        }
                        (detectedOrigin, detectedSize) =  (CGPoint(x: parent.frame.origin.x + CGFloat(mLeft),y: parent.frame.origin.y + CGFloat(mTop)), CGSize(width: parent.frame.size.width - CGFloat(mLeft + mRight), height: parent.frame.size.height - CGFloat(mTop + mBottom)))
                    } else {
                        (x, y) = (comps[0], comps[1])
                    }
                } else if comps.count == 1 {
                    (x, y) = (comps[0], comps[0])
                }
                if x.contains("*") {
                    let components = x.components(separatedBy: "*")
                    if components.count > 1 {
                        let sComponenets = components[0].components(separatedBy: "/")
                        if sComponenets.count > 1, let uPart = Double(sComponenets[0]), let part = Double(sComponenets[1]), let pos = Double(components[1]) {
                            detectedOrigin = CGPoint(x: CGFloat(CGFloat(1)/CGFloat(part)) * CGFloat(pos - 1) * parent.frame.width, y: 0)
                            detectedSize = CGSize(width: CGFloat(CGFloat(uPart)/CGFloat(part)) * parent.frame.width, height: 0)
                        }
                    }
                } else if x.contains("/") {
                    let components = x.components(separatedBy: "/")
                    if components.count > 1, let pos = Double(components[0]), let size = Double(components[1]) {
                        detectedOrigin = CGPoint(x: pos, y: 0)
                        detectedSize = CGSize(width: size, height: 0)
                    }
                } else if let x = Double(x) {
                    detectedOrigin = CGPoint(x: 0, y: 0)
                    detectedSize = CGSize(width: parent.frame.size.width/CGFloat(x), height: 0)
                }
                if y.contains("*") {
                    let components = y.components(separatedBy: "*")
                    if components.count > 1 {
                        let sComponenets = components[0].components(separatedBy: "/")
                        if sComponenets.count > 1, let uPart = Double(sComponenets[0]), let part = Double(sComponenets[1]), let pos = Double(components[1]) {
                            detectedOrigin = CGPoint(x: detectedOrigin.x, y: CGFloat(CGFloat(CGFloat(1)/CGFloat(part)) * CGFloat(pos - 1) * parent.frame.height))
                            detectedSize = CGSize(width: detectedSize.width, height: CGFloat(CGFloat(CGFloat(uPart)/CGFloat(part)) * parent.frame.height))
                        }
                    }
                } else if y.contains("/") {
                    let components = y.components(separatedBy: "/")
                    if components.count > 1, let pos = Double(components[0]), let size = Double(components[1]) {
                        detectedOrigin = CGPoint(x: detectedOrigin.x, y: CGFloat(pos))
                        detectedSize = CGSize(width: detectedSize.width, height: CGFloat(size))
                    }
                } else if let y = Double(y) {
                    detectedOrigin = CGPoint(x: detectedOrigin.x, y: 0)
                    detectedSize = CGSize(width: detectedSize.width, height: parent.frame.size.height/CGFloat(y))
                }
            }
        })
        object.string(viewParams.size) {size in
            if size.contains(",") {
                let comps = Frame.replaceRect(size, CGRect(origin: detectedOrigin, size: detectedSize), parent.frame, parentAView: aview).components(separatedBy: ",")
                if comps.count > 1, let width = Int(comps[0]), let height = Int(comps[1]) {
                    detectedSize = CGSize(width: width, height: height)
                }
            }
        }
        object.string(viewParams.origin) {origin in
            if origin.contains(",") {
                let comps = Frame.replaceRect(origin, CGRect(origin: detectedOrigin, size: detectedSize), parent.frame, parentAView: aview).components(separatedBy: ",")
                if comps.count > 1, let x = Int(comps[0]), let y = Int(comps[1]) {
                    detectedOrigin = CGPoint(x: x, y: y)
                }
            }
        }
        object.string(viewParams.width, {
            if let wh = Frame.calculate(Frame.replaceRect($0, CGRect(origin: detectedOrigin, size: detectedSize), parent.frame, parentAView: aview)) {
                detectedSize = CGSize(width: CGFloat(wh), height: detectedSize.height)
            }
        })
        object.string(viewParams.height, {
            if let hg = Frame.calculate(Frame.replaceRect($0, CGRect(origin: detectedOrigin, size: detectedSize), parent.frame, parentAView: aview)) {
                detectedSize = CGSize(width: detectedSize.width, height: CGFloat(hg))
            }
        })
        
        object.string([viewParams.x], {
            if $0 == "center" {
                detectedOrigin = CGPoint(x: (parent.frame.width - detectedSize.width)/2, y: detectedOrigin.y)
            } else if $0 == "end" {
                detectedOrigin = CGPoint(x: parent.frame.width - detectedSize.width, y: detectedOrigin.y)
            } else if let x = Frame.calculate(Frame.replaceRect($0, CGRect(origin: detectedOrigin, size: detectedSize), parent.frame, parentAView: aview)) {
                detectedOrigin = CGPoint(x: CGFloat(x), y: detectedOrigin.y)
            }
        })
        object.string([viewParams.y], {
            if $0 == "center" {
                detectedOrigin = CGPoint(x: detectedOrigin.x, y: (parent.frame.height - detectedSize.height)/2)
            } else if $0 == "end" {
                detectedOrigin = CGPoint(x: detectedOrigin.x, y: parent.frame.height - detectedSize.height)
            } else if let y = Frame.calculate(Frame.replaceRect($0, CGRect(origin: detectedOrigin, size: detectedSize), parent.frame, parentAView: aview)) {
                detectedOrigin = CGPoint(x: detectedOrigin.x, y: CGFloat(y))
            }
        })
        
        object.double(viewParams.widthRatio) {
            detectedSize = CGSize(width: CGFloat($0) * detectedSize.height, height: detectedSize.height)
        }
        object.double(viewParams.heightRatio) {
            detectedSize = CGSize(width: detectedSize.width, height: CGFloat($0) * detectedSize.width)
        }
        
        object.string(viewParams.padding, {_pad in
            var pad = _pad
            let parts = pad.components(separatedBy: catchPhrases.partsDivider)
            if parts.count == 2 {
                for part in parts {
                    let parts2 = part.components(separatedBy: catchPhrases.valueDivider)
                    if parts2.count == 2 {
                        if parts2[0].lowercased().compare(viewParams.iphone), UIDevice.current.userInterfaceIdiom == .phone {
                            pad = parts2[1]
                        } else if parts2[0].lowercased().compare(viewParams.ipad), UIDevice.current.userInterfaceIdiom == .pad {
                            pad = parts2[1]
                        }
                    }
                }
            }
            pad = Frame.replaceRect(pad, CGRect(origin: detectedOrigin, size: detectedSize), parent.frame, parentAView: aview)
            if pad.contains(",") {
                var (mLeft, mRight, mTop, mBottom) = (0.0,0.0,0.0,0.0)
                let compss = pad.components(separatedBy: ",")
                if compss.count == 2 {
                    if let m1 = Frame.calculate(compss[0]), let m2 = Frame.calculate(compss[1]) {
                        (mLeft, mRight, mTop, mBottom) = (m1,m1,m2,m2)
                    }
                } else if compss.count == 4 {
                    if let m1 = Frame.calculate(compss[0]), let m2 = Frame.calculate(compss[1]), let m3 = Frame.calculate(compss[2]), let m4 = Frame.calculate(compss[3]) {
                        (mTop, mRight, mBottom, mLeft) = (m1,m2,m3,m4)
                    }
                }
                (detectedOrigin, detectedSize) =  (CGPoint(x: detectedOrigin.x + CGFloat(mLeft),y: detectedOrigin.y + CGFloat(mTop)), CGSize(width: detectedSize.width - CGFloat(mLeft + mRight), height: detectedSize.height - CGFloat(mTop + mBottom)))
            } else if let padding = Frame.calculate(pad) {
                detectedOrigin = CGPoint(x: detectedOrigin.x + CGFloat(padding), y: detectedOrigin.y + CGFloat(padding))
                detectedSize = CGSize(width: detectedSize.width - CGFloat(padding * 2), height: detectedSize.height - CGFloat(padding * 2))
            }
        })
//        object.int(viewParams.x, {x in
//            object.int(viewParams.y, {y in
//                detectedOrigin = CGPoint(x: CGFloat(x), y: CGFloat(y))
//            })
//        })
//        } else {
//            object.string(vp.size, {(size: String) in
//                if size.contains("x") {
//                    let wh = size.components(separatedBy: "x")
//                    if wh.count > 1 {
//                        if let w = Int(wh[0]), let h = Int(wh[1]) {
//                            detectedSize = CGSize(width: w, height: h)
//                        }
//                    }
//                }
//            })
//            if detectedSize == nil {object.XML(vp.size, {(size: XML) in
//                var (wh, hg) = (0, 0)
//                
//                size.int(vp.width, {(width: Int) in
//                    wh = width
//                })
//                size.int(vp.height, {(height: Int) in
//                    hg = height
//                })
//        
//                if wh == 0 {size.string(vp.width, {(width: String) in
//                    if width.contains("%") {
//                        if let pers = Int(width.replacingOccurrences(of: "%", with: "")) {
//                            wh = Int((CGFloat(pers)/100) * parent.frame.size.width)
//                        }
//                    }
//                })}
//                if hg == 0 {size.string(vp.height, {(height: String) in
//                    if height.contains("%") {
//                        if let pers = Int(height.replacingOccurrences(of: "%", with: "")) {
//                            hg = Int((CGFloat(pers)/100) * parent.frame.size.height)
//                        }
//                    }
//                })}
//                detectedSize = CGSize(width: wh, height: hg)
//            })}
//            
//            if let pos = object[vp.position].string {
//                if pos.contains(":") {
//                    let xy = pos.components(separatedBy: ":")
//                    if xy.count > 1 {
//                        if let x = Int(xy[0]), let y = Int(xy[1]) {
//                            detectedOrigin = CGPoint(x: x, y: y)
//                        }
//                    }
//                } else if pos.contains("center") {
//                    if let sz = detectedSize {
//                        detectedOrigin = CGPoint(x: parent.frame.size.width/2 - sz.width/2, y: parent.frame.size.height/2 - sz.height/2)
//                    }
//                }
//            }
//        }
//        if detectedOrigin != nil, detectedSize != nil {
//            detectedOrigin = CGPoint(x: (detectedOrigin?.x)!, y: parent.frame.size.height - (detectedSize?.height)! - (detectedOrigin?.y)!)
//        }
        return (detectedOrigin, detectedSize)
    }
    
    static func replaceRect(_ str: String, _ frame: CGRect, _ pFrame: CGRect = CGRect.zero, parentAView: AmytisView? = nil) -> String {
        var _str = str
        
        var values: [String: CGFloat] = [
            "p.h": pFrame.height,
            "p.w": pFrame.width,
            "p.y": pFrame.origin.y,
            "p.x": pFrame.origin.x
        ]
        
        if let paview = parentAView {
            for (name, view) in paview.views {
                if let v = view as? UIView {
                    values["\(name).h"] = v.frame.height
                    values["\(name).w"] = v.frame.width
                    values["\(name).y"] = v.frame.origin.y
                    values["\(name).x"] = v.frame.origin.x
                }
            }
        }
        
        for (name, value) in values {
            _str = _str.replacingOccurrences(of: name, with: "\(value)")
        }
        
        values = [
            "h": frame.height,
            "w": frame.width,
            "y": frame.origin.y,
            "x": frame.origin.x
        ]
        
        for (name, value) in values {
            _str = _str.replacingOccurrences(of: name, with: "\(value)")
        }
        
        return _str
    }
    
    static func calculate(_ str: String) -> Double? {
        if let val = Double(str) {
            return val
        } else if str.contains(only: "+-*/%^1234567890(). ") {
            let expn = NSExpression(format: str)
            let _val = expn.expressionValue(with: nil, context: nil)
            if let val = _val as? Int {
                return Double(val)
            } else if let val = _val as? Double {
                return val
            } else if let val = _val as? Float {
                return Double(val)
            }
        }
        return nil
    }
    
}

extension String {
    
    func contains(range: String) -> Bool {
        for c in range.characters {
            if self.contains(c) {
                return true
            }
        }
        return false
    }
    
    func contains(only: String) -> Bool {
        for c in characters {
            if !only.contains(c) {
                return false
            }
        }
        return true
    }
    
}
