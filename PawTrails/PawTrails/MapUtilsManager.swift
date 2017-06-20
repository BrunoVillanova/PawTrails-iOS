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
    var id: Int16
    var location: CLLocation
    var placemark: CLPlacemark?
    
    init(type: GeocodeType, id: Int16, location: CLLocation, placemark: CLPlacemark? = nil) {
        self.type = type
        self.id = id
        self.location = location
        self.placemark = placemark
    }
    
    var name: String? {
        return placemark?.thoroughfare ?? placemark?.name
    }
}

class GeocoderManager {
    
    static let Intance = GeocoderManager()
    
    private var queue: DispatchQueue
    private var geocoder: CLGeocoder
    private var cache: NSCache<NSString, CLPlacemark>
    private var sem: DispatchSemaphore
    private let maxConcurrent = 5
    
    init() {
        queue = DispatchQueue(label: "GeoCode", qos: .userInitiated)
        geocoder = CLGeocoder()
        cache = NSCache<NSString, CLPlacemark>()
        sem = DispatchSemaphore(value: maxConcurrent)
    }
    
    func reverse(type: GeocodeType, with point: Point, for id: Int16){
        reverse(type: type, with: point.coordinates.location, for: id)
    }
    
    func reverse(type: GeocodeType, with location: CLLocation, for id: Int16){
        
        let key = location.coordinateString
        
        if let placemark = cache.object(forKey: key as NSString) {
            deliver(Geocode(type: type, id: id, location: location, placemark: placemark))
        }else {
            
            
            queue.async {
                self.sem.wait()
                self.geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in

                    if let placemark = placemarks?.first {

                        self.cache.setObject(placemark, forKey: location.coordinateString as NSString)
                        self.deliver(Geocode(type: type, id: id, location: location, placemark: placemark))
                    }
                    self.sem.signal()
                })
            }
        }
    }
    private func deliver(_ geocode: Geocode){
        DispatchQueue.main.async {
            
            if let name = geocode.name {
                
                if geocode.type == .pet {
                    SocketIOManager.Instance.setPetGPSlocationName(id: geocode.id, name)
                }else if geocode.type == .safezone {
                    DataManager.Instance.setSafeZone(address: name, for: geocode.id)
                }
                NotificationManager.Instance.postPetGeoCodeUpdates(with: geocode)
            }
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
        
        _ = mapView.load(with: center, topCenter: topCenter, shape: shape, into: view, paintShapes: true)
        
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




































