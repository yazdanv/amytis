//
//  GMap.swift
//  Pods
//
//  Created by Yazdan on 5/13/17.
//
//

import UIKit
import JavaScriptCore

//#if GoogleMaps
//import GoogleMaps
//import GooglePlaces
//
//@objc public protocol GMapJSExport: JSExport {
////    var changed: JSValue! { get set }
////    var pinClicked: JSValue! { get set }
////    var radius: Int { get set }
//    var type: String { get set }
////    func center(_ lat: Any, _ lng: Any)
////    func current(_ lat: Any, _ lng: Any)
////    func addPin(_ key: String, _ lat: Any, _ lng: Any, _ params: [String: Any])
////    func line(_ locs: Any)
////    func route(_ locs: Any)
//}
//
//public class GMap: UIView, GMapJSExport {
//    
//    var id: String?
//    var frame2: Frame!
//    var map: GMSMapView!
//    var shouldUpdateLocation = false {didSet {self.updateLocation()}}
//    var zoomLevel: Float = 6.0
//    var _type: String = "standard"
//    var type: String {
//        set {
//            runAsync {
//                if newValue.compare(mapParams.standard) {
//                    self.map.mapType = GMSMapViewType.normal
//                    self._type = "standard"
//                } else if newValue.compare(mapParams.hybrid) {
//                    self.map.mapType = GMSMapViewType.hybrid
//                    self._type = "hybrid"
//                } else if newValue.compare(mapParams.satellite) {
//                    self.map.mapType = GMSMapViewType.satellite
//                    self._type = "satellite"
//                }  else if newValue.compare(mapParams.terrain) {
//                    self.map.mapType = GMSMapViewType.terrain
//                    self._type = "terrain"
//                }
//            }
//        }
//        get {
//            return _type
//        }
//    }
//    
//    var anots: [String: MapItem] = [:]
//    var pinsXML: [String: XML] = [:]
//    
//    convenience init( _ parent: AmytisView, _ rect: Frame, _ object: XML) {
//        self.init(frame: CGRect(origin: rect.origin, size: rect.size))
//        self.runAsync {self.backgroundColor = .white}
//        self.setViewParams(object, parent)
//        self.frame2 = rect
//        config(object)
//        frame2.rotate = {self.frame.size = self.frame2.size; self.frame.origin = self.frame2.origin}
//    }
//    
//    deinit {
//        id = nil
//        frame2 = nil
//    }
//    
//    func empty() {
//        id = nil
//        if frame2 != nil {
//            frame2.empty()
//            frame2 = nil
//        }
//    }
//    
//    func updateLocation() {
//        if shouldUpdateLocation {
//            locationJSSharedInstance.changed = {(location: CLLocation) in
//
//            }
//            locationJSSharedInstance.start()
//        } else {
//            locationJSSharedInstance.stop()
//        }
//    }
//    
//    func config(_ object: XML) {
//        object.string(topParams.key, {key in
//            GMSServices.provideAPIKey(key)
//            GMSPlacesClient.provideAPIKey(key)
//        })
//        var camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: zoomLevel)
//        object.float(mapParams.zoomLevel, {level in
//            self.zoomLevel = level
//        })
//        object.xml(mapParams.center) {center in
//            center.double(mapParams.latitude) {lat in
//                center.double(mapParams.longitude) {lng in
//                    camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: zoomLevel)
//                }
//            }
//        }
//        
//        runAsync {
//            self.map = GMSMapView.map(withFrame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame2.size), camera: camera)
//            self.addSubview(self.map)
//            object.string(viewParams.type, {type in
//                self.type = type
//            })
//            object.bool(mapParams.current, {current in
//                self.map.isMyLocationEnabled = current
//            })
//            object.bool(mapParams.locationBtn, {btnEnabled in
//                self.map.settings.myLocationButton = btnEnabled
//            })
//            object.bool(mapParams.showsTraffic, {traffic in
//                self.map.isTrafficEnabled = traffic
//            })
//            
//        }
//        if let xmls = object["pin"].all{
//            for xml in xmls {
//                xml.string(viewParams.classs, {classs in
//                    pinsXML[classs] = xml
//                })
//            }
//        }
//        
//    }
//    
//    public func addPins(_ key: String, _ locs: Any, _ params: Any) {
//        var locations: [CLLocationCoordinate2D] = locationJSSharedInstance.create(locs)
//        var prms: [[String: Any]] = []
//        if let param = params as? [String: Any] {
//            prms = [param]
//        } else if let param = params as? [[String: Any]] {
//            prms = param
//        }
//        if prms.count == 0, let loc = locs as? [String: Any] {
//            prms = [loc]
//        } else if prms.count == 0, let loc = locs as? [[String: Any]] {
//            prms = loc
//        }
//        for i in 0...(locations.count-1) {
//            let location = locations[i]
//            var param: [String: Any]!
//            if prms.count > i {
//                param = prms[i]
//            } else {
//                param = prms.last
//            }
//            let json = JSON(data: NSKeyedArchiver.archivedData(withRootObject: param))
//            var id: String?
//            if let i = param["id"] {
//                id = String(describing: i)
//            }
//            if let xml = pinsXML[key]?.params(objects: json) {
//                xml.int(viewParams.width, {width in
//                    xml.int(viewParams.height, {height in
//                        let item = GMapItem(xml, width: width, height: height, coordinate: location, id: id)
//                        item.map = self.map
//                    })
//                })
//            }
//        }
//
//    }
//    
//    
//}
//
//class GMapItem: GMSMarker {
//    
//    let xml: XML
//    let AmytisView: AmytisView
//    var id: String?
//    var popUp: UIView?
//    
//    init(_ xml: XML, width: Int, height: Int, coordinate: CLLocationCoordinate2D, id: String? = nil) {
//        self.xml = xml
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        AmytisView = view.createAmytisView()
//        view.setViewParams(xml, AmytisView)
//        AmytisView.populateWith(xmlArr: xml.children)
//        let pop = xml[viewParams.popUp]
//        super.init()
//        self.iconView = view
//        self.position = coordinate
//        if pop.error != AEXMLError.elementNotFound {
//            pop.int(viewParams.width, {wd in
//                pop.int(viewParams.height, {hg in
//                    let popup = UIView(frame: CGRect(x: width/2 - wd/2, y: -hg - 8, width: wd, height: hg))
//                    let xmlV = popup.createAmytisView()
//                    xmlV.populateWith(xmlArr: pop.children)
//                    popup.setViewParams(pop, xmlV)
//                    self.popUp = popup
//                })
//            })
//        }
//        self.id = id
//    }
//}
//#else
    typealias GMap = Map
//#endif

