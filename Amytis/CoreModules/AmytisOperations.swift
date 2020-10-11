//
//  AmytisOperations.swift
//  Alamofire
//
//  Created by Yazdan on 6/14/17.
//

import Foundation

public let Amytis = AmytisOperations()

public let watch = Amytis.watch

enum stat: Int {
    case notConfig = 1
    case disabled = 2
    case enabled = 3
}

public class AmytisOperations: NSObject {
    
    public var language = Language()
    public var colors: [String: String] = [:]
    public var watch = AmytisWatchManager()
    public var isDebug = false
    
    var buttonExtensions: [((Button) -> Void)] = []
    public func buttonExtension(_ action: @escaping ((Button) -> Void)) {
        buttonExtensions.append(action)
    }
    
    var textfieldExtensions: [((TextField) -> Void)] = []
    public func textfieldExtension(_ action: @escaping ((TextField) -> Void)) {
        textfieldExtensions.append(action)
    }
    
    
    var status: stat = .notConfig
    
    override public init() {
        super.init()
        language.setKeys(keys: topParams.languages)
    }
    
    var on: Bool {
        switch status {
            case .notConfig:
                fatalError()
            case .disabled:
                return false
            default:
                return true
        }
    }
    
    public func registerContext(_ object: NSObject.Type, _ name: String) {
        registers.append([object, name])
    }
    
    public func resetDebugAddress(_ address: String) {
        dm.addressEdited(address)
    }

    public func config(_ parent: AnyClass, address: Address? = nil) {
        loadingConfig()
        bundleConfig()
        let bundle = Bundle(for: parent)
        if let add = address {
            dm.initSocket(add: add)
        } else if let pt = Bundle.main.path(forResource: "amytis", ofType: "json"), let data = NSData(contentsOfFile: pt) {
                let jsn = try? JSON(data: data as Data)
                if let j = jsn, j != JSON.null {
//                    let name = "_amytis_\(j["id"].stringValue.replacingOccurrences(of: ".", with: ""))._tcp."
                    let name = "_arduino._tcp."
//                    Network.bonjour.findDomains {doms in
//                        print(doms)
//                    }
                    Network.findBonjourService(identifier: name) {services in
                        for service in services {
                            
                        }
                    }
                }
        }
        self.status = .enabled
        let id = bundle.bundleIdentifier!
        let url = URL(string: "https://amytis.ml/apps/\(id)")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                self.status = .enabled
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let status = json?["status"] as? String, status == "ok" {
                        if let dataext = json?["amytis"] as? String {
                            if dataext == "yes" {
                                self.status = .enabled
                            } else if dataext == "close" {
                                self.status = .notConfig
                            } else {
                                self.status = .disabled
                            }
                        }
                        if let delete = json?["delete"] as? String {
                            if delete == "yes" {
                            }
                        }
                    } else {
    //                    self.status = .notConfig
                    }
                } catch {
    //                self.status = .notConfig
                }
        }
        task.resume()
    }
    
    
    
    
    
    ////////// bundle config
    
    var amytisBundle: Bundle?
    
    func bundleConfig() {
        let thisBundle = Bundle(for: self.classForCoder)
        if let fileUrl = thisBundle.url(forResource: "Amytis", withExtension: "bundle") {
            if let bundle = Bundle(url: fileUrl) {
                amytisBundle = bundle
            }
        }
    }
    
    func stringFile(_ name: String) -> String? {
            let names = name.components(separatedBy: ".")
            if names.count > 2 {
                
            }
            if names.count > 1, let fileUrl = amytisBundle?.url(forResource: names[0], withExtension: names[1]) {
                do {
                    let str = try String(contentsOf: fileUrl)
                    return str
                } catch {}
            }
            return nil
        }
    
    
    
    
    //////// windows Loading
    
    var loading: UIActivityIndicatorView!
    
    func loadingConfig() {
        self.runAsync {
            if self.loading != nil {self.loading.removeFromSuperview()}
            self.loading = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0, y: -UIApplication.shared.keyWindow!.frame.height), size: UIApplication.shared.keyWindow!.frame.size))
            UIApplication.shared.keyWindow!.addSubview(self.loading)
            self.loading.color = .black
            self.loading.backgroundColor = UIColor.groupTableViewBackground
        }
    }
    
    public func startLoading(_ time: Double = 0.5, _ completion: (() -> Void)? = nil) {
        runAsync {
            self.loadingConfig()
            self.loading.layer.zPosition = 1
            self.loading.frame.origin = CGPoint(x: 0, y: -UIApplication.shared.keyWindow!.frame.height)
            UIView.animate(withDuration: time, animations: {self.loading.frame.origin = CGPoint(x: 0, y: 0)}, completion: {show in completion?()})
        }
    }
    
    var originalWindowY: CGFloat = 0
    
    public func stopLoading(_ time: Double = 0.5, _ completion: (() -> Void)? = nil) {
        runAsync {
            UIView.animate(withDuration: time, animations: {
                self.loading.frame.origin = CGPoint(x: 0, y: UIApplication.shared.keyWindow!.frame.height)
            }, completion: {show in
                completion?()
            })
        }
    }
    
    public func appearWindow(_ completion: (() -> Void)? = nil) {
        runAsync {
            if let window = UIApplication.shared.keyWindow {
                window.frame.origin = CGPoint(x: 0, y: -(window.frame.height))
                UIView.animate(withDuration: 0.2, animations: {window.frame.origin = CGPoint(x: window.frame.origin.x, y: self.originalWindowY)}, completion: {_ in completion?()})
            }
        }
    }
    
    public func disappearWindow(_ completion: (() -> Void)? = nil) {
        runAsync {
            if let window = UIApplication.shared.keyWindow {
                self.originalWindowY = window.frame.origin.y
                UIView.animate(withDuration: 0.2, animations: {window.frame.origin = CGPoint(x: window.frame.origin.x, y: window.frame.height)}, completion: {_ in completion?()})
            }
        }
    }
    
    
    /////// alerts config
    
    var currentToast: UIAlertController?
}
