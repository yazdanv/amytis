//
//  UIView.swift
//  AmytisViews
//
//  Created by Yazdan on 3/16/17.
//  Copyright © 2017 Yazdan. All rights reserved.
//

import UIKit

public protocol UIViewExtensions { }

public extension UIViewExtensions where Self: UIView {
    
    public func createAmytisView(viewDidLoad: (() -> Void)? = nil, controller: AmytisController? = nil, parent: AmytisView? = nil) -> AmytisView {
        return AmytisView(self, viewDidLoad, controller, parent: parent)
    }
    
}

extension UIView: UIViewExtensions {}


extension UIView {
    func setViewParams(_ object: XML, _ parent: AmytisView, padding: Bool = false, main: Bool = false) {
        if !main {self.backgroundColor = .clear}
        object.string(viewParams.background) {bg in
            if let v = self as? Button {
                if let image = Image.load(bg.replacingOccurrences(of: "local:", with: "")) {
                    v.setBackgroundImage(image, for: .normal)
                }
            } else if let v = self as? TextField {
                if let image = Image.load(bg.replacingOccurrences(of: "local:", with: "")) {
                    v.background = image
                }
            } else if let v = self as? View {
                if v.AmytisView != nil {
                    if let img = v.image("theBackgroundOfView") {
                        img.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: v.frame.size)
                        img.setSource(bg)
                    } else {
                        let img = ImageView(v.AmytisView, id: "theBackgroundOfView")
                        img.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: v.frame.size)
                        img.setSource(bg)
                    }
                } else {
                    v.AmytisView = v.createAmytisView(parent: v.parent)
                    let img = ImageView(v.AmytisView, id: "theBackgroundOfView")
                    img.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: v.frame.size)
                    img.setSource(bg)
                }
            } else if main {
                if let img = parent.image("theBackgroundOfView") {
                    img.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
                    img.setSource(bg)
                } else {
                    let img = ImageView(parent, id: "theBackgroundOfView")
                    img.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
                    img.setSource(bg)
                }
            }
        }
        object.bool(viewParams.interaction, {self.isUserInteractionEnabled = $0})
        object.yes(viewParams.circle) {
            let rect = self.frame
            let computedSize = CGSize(width: CGFloat((rect.width + rect.height) / 2), height: CGFloat((rect.width + rect.height) / 2))
            self.frame = CGRect(origin: CGPoint(x: rect.origin.x - CGFloat((computedSize.width - rect.width) / 2), y: rect.origin.y - CGFloat((computedSize.height - rect.height) / 2)), size: computedSize)
            self.clipsToBounds = true
            self.layer.cornerRadius = CGFloat(computedSize.width/2)
        }
        object.yes(viewParams.square) {
            let rect = self.frame
            let computedSize = CGSize(width: CGFloat((rect.width + rect.height) / 2), height: CGFloat((rect.width + rect.height) / 2))
            self.frame = CGRect(origin: CGPoint(x: rect.origin.x - CGFloat((computedSize.width - rect.width) / 2), y: rect.origin.y - CGFloat((computedSize.height - rect.height) / 2)), size: computedSize)
        }
        for i in 1...2 {
            var types = viewParams.tinsets
            if i == 2 {
                types = viewParams.iinsets
            }
            var (mLeft, mRight, mTop, mBottom) = (0,0,0,0)
            object.string(types, {pad in
                if pad.contains(",") {
                    (mLeft, mRight, mTop, mBottom) = (0,0,0,0)
                    let compss = pad.components(separatedBy: ",")
                    if compss.count == 2 {
                        if let m1 = Int(compss[0]), let m2 = Int(compss[1]) {
                            (mLeft, mRight, mTop, mBottom) = (m1,m1,m2,m2)
                        }
                    } else if compss.count == 4 {
                        if let m1 = Int(compss[0]), let m2 = Int(compss[1]), let m3 = Int(compss[2]), let m4 = Int(compss[3]) {
                            (mTop, mRight, mBottom, mLeft) = (m1,m2,m3,m4)
                        }
                    }
                } else if let padding = Int(pad) {
                    (mLeft, mRight, mTop, mBottom) = (padding,padding,padding,padding)
                }
            })
            if let s = self as? UIButton {
                if i == 2 {
                    s.imageEdgeInsets = UIEdgeInsets.init(top: CGFloat(mTop), left: CGFloat(mLeft), bottom: CGFloat(mBottom), right: CGFloat(mRight))
                } else {
                    s.titleEdgeInsets = UIEdgeInsets.init(top: CGFloat(mTop), left: CGFloat(mLeft), bottom: CGFloat(mBottom), right: CGFloat(mRight))
                }
            }
        }
        if padding {
            object.string(viewParams.padding, {pad in
                var frm = self.frame
                let dr = frm.origin
                let ds = frm.size
                if pad.contains(",") {
                    var (mLeft, mRight, mTop, mBottom) = (0,0,0,0)
                    let compss = pad.components(separatedBy: ",")
                    if compss.count == 2 {
                        if let m1 = Int(compss[0]), let m2 = Int(compss[1]) {
                            (mLeft, mRight, mTop, mBottom) = (m1,m1,m2,m2)
                        }
                    } else if compss.count == 4 {
                        if let m1 = Int(compss[0]), let m2 = Int(compss[1]), let m3 = Int(compss[2]), let m4 = Int(compss[3]) {
                            (mTop, mRight, mBottom, mLeft) = (m1,m2,m3,m4)
                        }
                    }
                    (frm.origin, frm.size) = (CGPoint(x: dr.x + CGFloat(mLeft),y: dr.y + CGFloat(mTop)), CGSize(width: ds.width - CGFloat(mLeft + mRight), height: ds.height - CGFloat(mTop + mBottom)))
                } else if let padding = Int(pad) {
                    frm.origin = CGPoint(x: dr.x + CGFloat(padding), y: dr.y + CGFloat(padding))
                    frm.size = CGSize(width: ds.width - CGFloat(padding * 2), height: ds.height - CGFloat(padding * 2))
                }
                self.frame = frm
            })
        }
        object.string(vp.backgroundColor, { self.backgroundColor = UIColor.pickColor($0)})
        object.bool(vp.hidden, {self.isHidden = $0})
        object.double(viewParams.alpha, {self.alpha = CGFloat($0)})
        object.double(viewParams.elevation, { elevation in
            self.clipsToBounds = true
            self.layer.masksToBounds = false
            self.layer.shadowOffset = CGSize(width: -2, height: 3);
            self.layer.shadowRadius = CGFloat(elevation)
            self.layer.shadowOpacity = Float(0.1 * elevation)
        })
        object.double(viewParams.cornerRound, {
            self.clipsToBounds = true
            self.layer.cornerRadius = CGFloat($0)
        })
        object.yes(viewParams.leftGesture) {parent.configureSwipeGestures(.left)}
        object.yes(viewParams.rightGesture) {parent.configureSwipeGestures(.right)}
        object.yes(viewParams.upGesture) {parent.configureSwipeGestures(.up)}
        object.yes(viewParams.downGesture) {parent.configureSwipeGestures(.down)}
    }

    
}
