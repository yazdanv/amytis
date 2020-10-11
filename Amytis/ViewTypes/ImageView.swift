//
//  ImageView.swift
//  AmytisViews
//
//  Created by Yazdan on 3/16/17.
//  Copyright © 2017 Yazdan. All rights reserved.
//

import UIKit
import JavaScriptCore

@objc public protocol ImageViewJSExport: JSExport {
    func remove()
    func picked(_ action: @escaping ((UIImage) -> Void))
    func setSource(_ source: String)
}


public final class ImageView: UIImageView, AmytisViewType, ImageViewJSExport, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ExtendableView  {
    
    /////////////////////// extendable view protocol
    public var params: [String : Any] = [:]
    ////////////////////////////////////////////////
    
    //////////////////////////// coded view protocol
    var _id: String!
    public var id: String {
        get {return _id}
        set {_id = newValue}
    }
    var _frame: Frame!
    public var frame2: Frame {
        get {return _frame}
        set {_frame = newValue}
    }
    var _parent: AmytisView!
    public var parent: AmytisView {
        get {return _parent}
        set {_parent = newValue}
    }
    var _viewXML: XML!
    public var viewXML: XML {
        get {return _viewXML}
        set {_viewXML = newValue}
    }
    public func requiredInit() {
        
    }
    @objc public func reRenderWithChild(_ xml: String) {_reRender(xml)}
    @objc public func reRender(_ params: [String: Any]) {_reRender(params)}
    @objc public func reCalculateFrame(_ animated: Bool) {_reCalculateFrame(animated)}
    @objc public func animateToFrame(_ string: String, _ time: Double = 0.5, _ completion: JSValue? = nil) {
        _ = animateToFrame(string, time, {_ = completion?.call(withArguments: [])})
    }
    ///////////////////////////////////////////////
    public func hidden(_ _isHidden: Bool) -> Self {
        self.btn?.hidden(_isHidden)
        self.btn?.isEnabled = _isHidden
        return self
    }
    public func remove() {
        self.btn?.removeFromSuperview()
        self.removeFromSuperview()
    }
    public func contentType(_ type: String) -> Self {
        changeParameter(type, imageParams.contentType)
        return self
    }
    ///////////////////////////////////////////////
    var btn: Button?
    public var picked: ((UIImage) -> Void)?
    public func picked(_ action: @escaping ((UIImage) -> Void)) {
        self.picked = action
    }
    
    convenience init( _ parent: AmytisView, _ rect: Frame, _ object: XML) {
        self.init(frame: CGRect(origin: rect.origin, size: rect.size))
        self.parent = parent
        self.frame2 = rect
        self.viewXML = object
        self.setViewParams(object, parent)
        self.config()
        frame2.rotate = {self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin}
    }
    
    deinit {
        self.image = nil
    }
    
    func empty() {
        frame2.empty()
        self.image = nil
    }
    
    public func config() {
        self.contentMode = .scaleAspectFill
        self.viewXML.string(imageParams.contentType) {type in
            if type.compare(imageParams.contentTypes.aspectFit) {
                self.contentMode = .scaleAspectFit
            } else if type.compare(imageParams.contentTypes.fill) {
                self.contentMode = .scaleToFill
            } else if type.compare(imageParams.contentTypes.aspectFill) {
                self.contentMode = .scaleAspectFill
            }
        }
        if self.viewXML.string != "" {
            setSource(self.viewXML.str)
        } else {
            self.viewXML.string(imageParams.source, { (source: String) in
                self.setSource(source)
            })
        }
        self.viewXML.yes(imageParams.picker, {
            self.btn = Button(frame: self.frame)
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self.btn!.clicked {
                imagePicker.allowsEditing = true
                imagePicker.mediaTypes = ["public.image"]
                self.parent.controller.choices(title: Amytis.language.get("image_location")!, message: Amytis.language.get("from_library_or_camera")!, actions: [Amytis.language.get("photo_library")!: {
                        imagePicker.sourceType = .photoLibrary
                        self.parent.controller.present(imagePicker, animated: true, completion: nil)
                    }, Amytis.language.get("camera")!: {
                        imagePicker.sourceType = .camera
                        self.parent.controller.present(imagePicker, animated: true, completion: nil)
                    }])
            }
            self.parent.view.addSubview(self.btn!)
        })
    }
        
    public func setSource(_ source: String) {
        if source.contains("http") {
            self.image = Image.load(url: source) {img in
                self.image = img
            }
        } else {
            if let image = UIImage(named: source.replacingOccurrences(of: "local:", with: "")) {
                self.image = image
            } else if let image = Image.load(source.replacingOccurrences(of: "local:", with: "")) {
                self.image = image
            }
        }
    }

    func setImage(_ image: UIImage, id: String = "") {
        self.image = image
        setNotif(id, #selector(imageLoaded(notification:)))
    }
    @objc func imageLoaded(notification: Notification) {
        if let userdata = notification.userInfo, let image = userdata["image"] as? UIImage {
            self.image = image
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            self.image = image
            picked?(image)
        } else if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            self.image = image
            picked?(image)
        } else if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.cropRect)] as? UIImage {
            self.image = image
            picked?(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
