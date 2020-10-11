//
//  JSConsole.swift
//  Pods
//
//  Created by Yazdan on 5/7/17.
//
//

import Foundation
import JavaScriptCore
import MapKit

let locationJSSharedInstance = JSLocation()
public let location = locationJSSharedInstance


@objc public protocol LocationJSExport : JSExport {
    
    func start()
    func stop()
    func distance(_ locs: Any) -> Int
    
    var changed: Any { get set }
    var significent: Bool { get set }
    var latitude: Double { get }
    var longitude: Double { get }
    var altitude: Double { get }
    
}

// Custom class must inherit from `NSObject`
@objc public class JSLocation: NSObject, LocationJSExport, CLLocationManagerDelegate {
    
    var _changedJS: JSValue?
    var _changedSwift: ((CLLocation) -> Void)?
    var _changedSwift2: (() -> Void)?
    public var changed: Any {
        set {
            if let val = newValue as? JSValue {
                _changedJS = val
            } else if let val = newValue as? ((CLLocation) -> Void) {
                _changedSwift = val
            } else if let val = newValue as? (() -> Void) {
                _changedSwift2 = val
            }
        }
        get {
            if let val = _changedJS {
                return val
            } else if let val = _changedSwift {
                return val
            } else if let val = _changedSwift2 {
                return val
            }
            return ""
        }
    }
    var context: JSContext!
    var locationManager: CLLocationManager!
    public var significent: Bool = true {didSet{startUpdating()}}
    public var latitude: Double = 0.0
    public var longitude: Double = 0.0
    public var altitude: Double = 0.0
    
    static func registerInto(jsContext: JSContext?, forKeyedSubscript: String = "location") {
        if let jsContext = jsContext {
            locationJSSharedInstance.context = jsContext
            jsContext.setObject(locationJSSharedInstance,
                                forKeyedSubscript: forKeyedSubscript as (NSCopying & NSObjectProtocol))
        }
    }
    
    public func changed(_ action: ((CLLocation) -> Void)? = nil, _ action2: (() -> Void)? = nil) {
        self._changedSwift = action
        self._changedSwift2 = action2
    }
    
    public func start() {
        runAsync {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.checkPermissions()
        }
    }
    
    public func stop() {
        runAsync {
            if self.locationManager != nil {
                self.locationManager.stopUpdatingLocation()
                self.locationManager.stopMonitoringSignificantLocationChanges()
                self.locationManager = nil
            }
        }
    }
    
    func startUpdating() {
        if !self.significent {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    var getLocationHandler: ((Double, Double) -> Void)?
    
    public func getLocation(_ action: @escaping ((Double, Double) -> Void)) {
        if getLocationHandler == nil {
            getLocationHandler = action
            self.start()
        }
    }
    
    func checkPermissions() {
        if (CLLocationManager.authorizationStatus() == .authorizedAlways){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            startUpdating()
        } else if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse){
            locationManager.requestAlwaysAuthorization()
            startUpdating()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            startUpdating()
        }
        else if(status == .authorizedWhenInUse){
            locationManager.requestAlwaysAuthorization()
            startUpdating()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locationManager.location, let lat = locationManager.location?.coordinate.latitude, let lng = locationManager.location?.coordinate.longitude, let alt = locationManager.location?.altitude.binade {
            if let handler = getLocationHandler {
                handler(lat, lng)
                getLocationHandler = nil
                self.stop()
            }
            self.latitude = lat
            self.longitude = lng
            self.altitude = alt
            if let callback = _changedJS {
                callback.call(withArguments: [])
            }
            if let callback = _changedSwift {
                callback(loc)
            }
            if let callback = _changedSwift2 {
                callback()
            }
        }
    }
    
    public func create(_ locs: Any) -> [CLLocationCoordinate2D] {
        var lcss: [[String: Any]]?
        if let locs = locs as? [[String: Any]] {
            lcss = locs
        } else if let locs = locs as? [String: Any] {
            lcss = [locs]
        }
        if let locs = lcss {
            var locations: [CLLocationCoordinate2D] = []
            for loc in locs {
                var (lat, lng): (Double?, Double?)
                if let lt = loc["lat"] as? Double {
                    lat = lt
                } else if let lts = loc["lat"] as? String, let lt = Double(lts) {
                    lat = lt
                } else if let lt = loc["latitude"] as? Double {
                    lat = lt
                } else if let lts = loc["latitude"] as? String, let lt = Double(lts) {
                    lat = lt
                }
                if let lg = loc["lng"] as? Double {
                    lng = lg
                } else if let lgs = loc["lng"] as? String, let lg = Double(lgs) {
                    lng = lg
                } else if let lg = loc["longitude"] as? Double {
                    lng = lg
                } else if let lgs = loc["longitude"] as? String, let lg = Double(lgs) {
                    lng = lg
                }
                if lat != nil, lng != nil {
                    locations.append(CLLocationCoordinate2D(latitude: lat!, longitude: lng!))
                }
            }
            return locations
        }
        return []
    }
    
    public func distance(_ locs: Any) -> Int {
        var locations: [CLLocationCoordinate2D] = []
        if let lcs = locs as? [CLLocationCoordinate2D] {
            locations = lcs
        } else {
            locations = create(locs)
        }
        var distance = 0
        for i in 0...(locations.count - 2) {
            let loc1 = CLLocation(latitude: locations[i].latitude, longitude: locations[i].longitude)
            let loc2 = CLLocation(latitude: locations[i+1].latitude, longitude: locations[i+1].longitude)
            distance += Int(loc1.distance(from: loc2))
        }
        return distance
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }

}
