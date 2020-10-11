//
//  NetworkManager.swift
//  Amytis-iOS
//
//  Created by Yazdan Vakili on 3/18/18.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import NetworkExtension

public let Network = NetworkManager()

public class NetworkManager: NSObject {
    
//    var bonjour = Bonjour()
    
    public var wifiName: String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    public func connectAP(ssid: String, password: String? = nil, onError: (() -> Void)? = nil, action: @escaping ((@escaping (() -> Void)) -> Void)) {
//        self.runBack {
//            if #available(iOS 11.0, *) {
//                let cssid = self.wifiName
//                var configuration = NEHotspotConfiguration.init(ssid: ssid)
//                if let pass = password {configuration = NEHotspotConfiguration.init(ssid: ssid, passphrase: pass, isWEP: false)}
//                configuration.joinOnce = true
//                NEHotspotConfigurationManager.shared.apply(configuration) { (error) in
//                    if error != nil, cssid != ssid {
//                        onError?()
//                    } else {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//                            action({NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)})
//                        })
//                    }
//                }
//            } else {
//                // Fallback on earlier versions
//            }
//        }
    }

    public func findBonjourService(identifier: String, found: @escaping ([NetService]) -> Void) {
//        bonjour.findService(identifier, found: found)
    }
}

public extension String {
    func resolveHostname(_ failed: Bool = false) -> String {
        let h = self
        if !failed, let string = UserDefaults.standard.string(forKey: h) {
            return string
        } else {
            let host = CFHostCreateWithName(nil,h as CFString).takeRetainedValue();
            if CFHostStartInfoResolution(host, .addresses, nil) {
                var success2: DarwinBoolean = false;
                if let addresses = CFHostGetAddressing(host, &success2)?.takeUnretainedValue() as? NSArray, addresses.count > 0 {
                    let theAddress = addresses[0] as! NSData;
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                                   &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        if let numAddress = String(validatingUTF8: hostname) {
                            UserDefaults.standard.set(numAddress, forKey: h)
                            return numAddress
                        }
                    }
                }
            }
            return self
        }
    }
    
    func resolve(failed: Bool = false, action: @escaping ((String) -> Void)) {
        let q = DispatchQueue.init(label: "HostnameResolveThread", qos: DispatchQoS.init(qosClass: DispatchQoS.QoSClass.background, relativePriority: 1), attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        q.async {
            let ip = self.resolveHostname(failed)
            DispatchQueue.main.async {
                action(ip)
            }
        }
    }
}



//class Bonjour: NSObject, NetServiceBrowserDelegate {
//    var timeout: TimeInterval = 1.0
//    var serviceFoundClosure: (([NetService]) -> Void)!
//    var domainFoundClosure: (([String]) -> Void)!
//    struct Services {
//        static let AppleTalk_Filing: String = "_afpovertcp._tcp."
//        static let Network_File_System: String = "_nfs._tcp."
//        static let WebDAV_File_System: String = "_webdav._tcp."
//        static let File_Transfer: String = "_ftp._tcp."
//        static let Secure_Shell: String = "_ssh._tcp."
//        static let Remote_AppleEvents: String = "_eppc._tcp."
//        static let Hypertext_Transfer: String = "_http._tcp."
//        static let Remote_Login: String = "_telnet._tcp."
//        static let Line_Printer_Daemon: String = "_printer._tcp."
//        static let Internet_Printing: String = "_ipp._tcp."
//        static let PDL_Data_Stream: String = "_pdl-datastream._tcp."
//        static let Remote_IO_USB_Printer: String = "_riousbprint._tcp."
//        static let Digital_Audio_Access: String = "_daap._tcp."
//        static let Digital_Photo_Access: String = "_dpap._tcp."
//        static let iChat_Instant_Messaging_Deprecated: String = "_ichat._tcp."
//        static let iChat_Instant_Messaging: String = "_presence._tcp."
//        static let Image_Capture_Sharing: String = "_ica-networking._tcp."
//        static let AirPort_Base_Station: String = "_airport._tcp."
//        static let Xserve_RAID: String = "_xserveraid._tcp."
//        static let Distributed_Compiler: String = "_distcc._tcp."
//        static let Apple_Password_Server: String = "_apple-sasl._tcp."
//        static let Workgroup_Manager: String = "_workstation._tcp."
//        static let Server_Admin: String = "_servermgr._tcp."
//        static let Remote_Audio_Output: String = "_raop._tcp."
//        static let Xcode_Server: String = "_xcs2p._tcp."
//    }
//    static let LocalDomain: String = "local."
//
//    let serviceBrowser: NetServiceBrowser = NetServiceBrowser()
//    var services = [NetService]()
//    var domains = [String]()
//    var isSearching: Bool = false
//    var serviceTimeout: Timer = Timer()
//    var domainTimeout: Timer = Timer()
//
//    func findService(_ identifier: String, domain: String = "AmytisWatcher", found: @escaping ([NetService]) -> Void) -> Bool {
//        if !isSearching {
//            serviceBrowser.delegate = self
//            serviceTimeout = Timer.scheduledTimer(
//                timeInterval: self.timeout,
//                target: self,
//                selector: #selector(Bonjour.noServicesFound),
//                userInfo: nil,
//                repeats: false)
//            serviceBrowser.searchForServices(ofType: identifier, inDomain: domain)
//            serviceFoundClosure = found
//            isSearching = true
//            return true
//        }
//        return false
//    }
//
//    func findDomains(_ found: @escaping ([String]) -> Void) -> Bool {
//        if !isSearching {
//            serviceBrowser.delegate = self
//            domainTimeout = Timer.scheduledTimer(
//                timeInterval: self.timeout,
//                target: self,
//                selector: #selector(Bonjour.noDomainsFound),
//                userInfo: nil,
//                repeats: false)
//            serviceBrowser.searchForBrowsableDomains()
//            domainFoundClosure = found
//            isSearching = true
//            return true
//        }
//        return false
//    }
//
//    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService,
//                           moreComing: Bool) {
//        serviceTimeout.invalidate()
//        services.append(service)
//        if !moreComing {
//            serviceFoundClosure(services)
//            serviceBrowser.stop()
//            isSearching = false
//        }
//    }
//
//    func noServicesFound() {
//        serviceFoundClosure([])
//        serviceBrowser.stop()
//        isSearching = false
//    }
//
//    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String,
//                           moreComing: Bool) {
//        domainTimeout.invalidate()
//        domains.append(domainString)
//        if !moreComing {
//            domainFoundClosure(domains)
//            serviceBrowser.stop()
//            isSearching = false
//        }
//    }
//
//    func noDomainsFound() {
//        domainFoundClosure([])
//        serviceBrowser.stop()
//        isSearching = false
//    }
//}


public class Address: NSObject {
    private var _host: String = ""
    private var _port: Int = 0
    
    public var host: String {
        return _host
    }
    public var port: Int {
        return _port
    }
    
    public convenience init(_ host: String, _ port: Int = 80) {
        self.init()
        self._host = host
        self._port = port
    }
}
