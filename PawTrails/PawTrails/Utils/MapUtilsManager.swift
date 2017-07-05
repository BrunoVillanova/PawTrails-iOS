//
//  GeocoderManager.swift
//  PawTrails
//
//  Created by Marc Perello on 08/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import MapKit
import UIKit

public enum GeocodeType {
    case pet, safezone
}

public class Geocode{
    
    var type: GeocodeType
    var id: Int
    var location: CLLocation
    var placemark: CLPlacemark?
    
    init(type: GeocodeType, id: Int, location: CLLocation, placemark: CLPlacemark? = nil) {
        self.type = type
        self.id = id
        self.location = location
        self.placemark = placemark
    }
    
    var name: String {
        if let name = placemark?.name { return name }
        if let th = placemark?.thoroughfare { return th }
        if let subLocality = placemark?.subLocality { return subLocality }
        if let locality = placemark?.locality { return locality }
        return "-"
    }
}

class GeocoderManager {
    
    static let Intance = GeocoderManager()
    
    private var queue: DispatchQueue
    private var geocoder: CLGeocoder
    private var cache: NSCache<NSString, CLPlacemark>
    private var sem: DispatchSemaphore
    private let maxConcurrent = 1
    
    init() {
        queue = DispatchQueue(label: "GeoCode", qos: .userInitiated)
        geocoder = CLGeocoder()
        cache = NSCache<NSString, CLPlacemark>()
        sem = DispatchSemaphore(value: maxConcurrent)
    }
    
    func reverse(type: GeocodeType, with point: Point, for id: Int){
        reverse(type: type, with: point.coordinates.location, for: id)
    }
    
    func reverse(type: GeocodeType, with location: CLLocation, for id: Int){
        
        let key = location.coordinateString
        
        if let placemark = cache.object(forKey: key as NSString) {
            deliver(Geocode(type: type, id: id, location: location, placemark: placemark))
        }else {
            Reporter.debugPrint(file: "#file", function: "#function", "Geocode requested: ", id)
            queue.async {
                self.sem.wait()
                self.geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in

                    if let error = error {
                        self.placemark(error)
                    }else if let placemark = placemarks?.first {
                        self.cache.setObject(placemark, forKey: location.coordinateString as NSString)
                        self.deliver(Geocode(type: type, id: id, location: location, placemark: placemark))
                    }else{
                        self.placemarkNotFound(Geocode(type: type, id: id, location: location))
                    }
                })
            }
        }
    }
    
    private func deliver(_ geocode: Geocode){
        DispatchQueue.main.async {
            let name = geocode.name
            Reporter.debugPrint(file: "#file", function: "#function", "Geocode released: ", geocode.id, name)
            if geocode.type == .pet {
                SocketIOManager.instance.set(name, for: geocode.id)
                NotificationManager.instance.postPetGeoCodeUpdates(with: geocode)
                self.sem.signal()
            }else if geocode.type == .safezone {
                DataManager.instance.setSafeZone(address: name, for: geocode.id, callback: { (error) in
                    if let error = error {
                        Reporter.send(file: "#file", function: "#function", error, ["Geocode id ": geocode.id, "Geocode name ": name])
                    }else{
                        Reporter.debugPrint(file: "#file", function: "#function", "Geocode posted: ", geocode.id, name)
                        NotificationManager.instance.postPetGeoCodeUpdates(with: geocode)
                    }
                    self.sem.signal()
                })
            }
        }
    }
    
    private func placemarkNotFound(_ geocode: Geocode){
        DispatchQueue.main.async {
            Reporter.debugPrint(file: "#file", function: "#function", "Placemark not found for: ", geocode.id, geocode.type)
            self.sem.signal()
        }
    }
    
    private func placemark(_ error: Error){
        DispatchQueue.main.async {
            Reporter.debugPrint(file: "#file", function: "#function", "Placemark error: ", error)
            self.sem.signal()
        }
    }

    
}

class SnapshotMapManager {
    
    static let Intance = SnapshotMapManager()
    
    private var view: UIView
    private var mapView: MKMapView
    
    private let processQueue = DispatchQueue(label: "processQueue", qos: .userInitiated)
    private let snapshotQueue = DispatchQueue(label: "snapshotQueue")
    
    init() {
        
        view = UIView(frame: UIScreen.main.bounds)
        mapView = MKMapView(frame: view.frame)
        
        let camera = mapView.camera
        camera.pitch = 0.0
        mapView.setCamera(camera, animated: false)
        
    }
    
    func performSnapShot(with center: CLLocationCoordinate2D, topCenter: CLLocationCoordinate2D, shape: Shape, handler: @escaping ((UIImage?)->())){
        
        mapView.load(with: center, topCenter: topCenter, shape: shape, into: view, paintShapes: true) { (fence) in
            
            let options = MKMapSnapshotOptions()
            options.region = self.mapView.region
            options.scale = UIScreen.main.scale
            options.size = CGSize(width: 375, height: 200)
            options.mapType = .satellite
            options.showsBuildings = true
            options.showsPointsOfInterest = true
            options.camera = self.mapView.camera
            
            let shooter = MKMapSnapshotter(options: options)
            
            shooter.start(with: self.snapshotQueue, completionHandler: { (snapshot, error) in
                if error == nil, let snapshot = snapshot {
                    
                    let center = snapshot.point(for: center)
                    let topCenter = snapshot.point(for: topCenter)
                    
                    let frame = CGRect(center: center, topCenter: topCenter)
                    
                    let image = snapshot.image
                    
                    UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
                    image.draw(at: CGPoint.zero)
                    
                    let path = shape == .circle ? UIBezierPath(ovalIn: frame) : UIBezierPath(rect: frame)
                    Fence.idleColor.set()
                    path.fill()
                    
                    let imageWithSafeZone = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    handler(imageWithSafeZone)
                }else {
                    handler(nil)
                }
            })
        }
    }
    
}




































