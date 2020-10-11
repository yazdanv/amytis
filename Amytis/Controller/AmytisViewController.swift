//
//  AmytisViewController.swift
//  Pods
//
//  Created by Yazdan on 4/7/17.
//
//

import UIKit
//import SocketIO


//
//public class AmytisViewController: NSObject {
//
//    public var controller = mainController
//    public var view: AmytisView!
//
//    override init() {
//        super.init()
////        let tempView = UIView(frame: UIScreen.main.bounds)
////        view = tempView.createAmytisView(main: true, viewDidLoad: viewDidLoad)
////        let name = String(describing: type(of: self)).replacingOccurrences(of: "Controller", with: "").camelCaps.lowercased()
////        view.populateWith(name: name)
//    }
//
//    open func viewDidLoad() {
//
//    }
//
//}


//class AmytisViewController: UIViewController {
//
//    var AmytisView: AmytisView!
//    var socket: SocketIOClient!
//    var connected: Bool = false
//    var jsn = ""
//    var debug = false
//    var addField = ""
//    let u = UserDefaults.standard
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        AmytisView = view.createAmytisView()
//        if debug {
//            if let add = u.string(forKey: "address"), let url = URL(string: add) {
//                initSocket(url: url)
//            }
//            runWD(3) {
//                if !self.connected {
//                    self.AmytisView.populateWith(string: "<views bgc=\"grey\"><textfield id=\"textfield\" placeholder=\"address\" frame=\"4/5*1.5--1/8*1.5\" bgc=\"white\"/><button id=\"button\" text=\"login\" frame=\"4/5*1.5--1/8*3\" bgc=\"blue\"/></views>")
//                    self.AmytisView.viewDidLoad = {
//                        if let button = self.AmytisView.button("button") {
//                            button.addTarget(self, action: #selector(self.textfieldedited), for: .touchUpInside)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func initSocket(url: URL) {
//        socket = SocketIOClient(socketURL: url, config: [.log(false), .forcePolling(true)])
//
//        socket.on("connect") {data, ack in
//            self.connected = true
//            self.socket.emit("request-data", "")
//        }
//
//        socket.on("to-user") {data, ack in
//            if let text = data[0] as? String {
//                var txt = text.replacingOccurrences(of: catchPhrases.valueDividerShow, with: catchPhrases.valueDivider)
//                if !txt.contains("&amp;") {
//                    txt = txt.replacingOccurrences(of: "&", with: "&amp;")
//                }
//                self.handle(text: txt)
//            }
//        }
//        socket.connect()
//
//        AmytisView.populateWith(name: "main", execCode: true)
//    }
//
//    func textfieldedited() {
//        if let text = AmytisView.textfield("textfield")?.text, let url = URL(string: text) {
//            self.u.set(text, forKey: "address")
//            self.initSocket(url: url)
//        }
//    }
//
//    func handle(text: String) {
//        handleCommands(text: text)
//        let comps = text.components(separatedBy: " /////////////////////////// ")
//        if jsn != text, comps.count > 1 {
//            jsn = text
//            let name = comps[0]
//            let str = comps[1]
//            do {
//                let doc = try XMLDocument(xml: str)
//                if doc.error == nil {
//                    if name == "main" {
//                        AmytisView.populateWith(string: str)
//                    }
//                    u.set(str, forKey: name)
//                }
//            }catch{}
//        } else if jsn != text {
//            do {
//                let doc = try XMLDocument(xml: text)
//                if doc.error == nil {
//                    dm.set(doc)
//                }
//            }catch{}
//        }
//    }
//
//    func handleCommands(text: String) {
//        if text == "request" {
//            if let txt = UserDefaults.standard.string(forKey: "data") {
//                socket.emit("request-data", txt.replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "&amp;", with: "&"))
//            }
//        }
//    }
//
//}
//
public extension UIWindow {
//    convenience init() {
//        self.init(frame: UIScreen.main.bounds)
//        self.rootViewController = AmytisController()
//        self.makeKeyAndVisible()
//    }
}

