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
    
    private func placemarkNotFound(_ geocode: Geocode){
        DispatchQueue.main.async {
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Placemark not found for: ", geocode.id, geocode.type)
            self.sem.signal()
        }
    }
    
    private func placemark(_ error: Error){
        DispatchQueue.main.async {
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Placemark error: ", error)
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
        
        mapView.load(with: center, topCenter: topCenter, shape: shape, into: view, isBackground: true) { (fence) in
            
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




































