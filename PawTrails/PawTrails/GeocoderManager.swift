//
//  GeocoderManager.swift
//  PawTrails
//
//  Created by Marc Perello on 08/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import MapKit

public struct Geocode{
    var petId: Int16
    var location: CLLocation
    var placemark: CLPlacemark?
}

class GeocoderManager {
    
    static let Intance = GeocoderManager()
    
    private var geocoder: CLGeocoder
    private var cache: NSCache<NSString, CLPlacemark>
    
    init() {
        geocoder = CLGeocoder()
        cache = NSCache<NSString, CLPlacemark>()
    }
    
    func reverse(_ point: Point, for petId: Int16){
        reverse(point.coordinates.location, for: petId)
    }
    
    func reverse(_ location: CLLocation, for petId: Int16){

        if let placemark = cache.object(forKey: location.coordinateString as NSString) {
//            debugPrint("Cache for \(petId)")
            deliver(Geocode(petId: petId, location: location, placemark: placemark))
        }else {
//            debugPrint("Add to queue for \(petId)")
            request(location, for: petId)
        }
    }
    
    private func request(_ location: CLLocation, for petId: Int16){
        self.geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            debugPrint("Results \(String(describing: placemarks?.first))")
            if let placemark = placemarks?.first {
//                debugPrint("Geocode delivered for \(petId)")
                self.cache.setObject(placemark, forKey: location.coordinateString as NSString)
                self.deliver(Geocode(petId: petId, location: location, placemark: placemark))
            }
        })
    }
    
    private func deliver(_ geocode: Geocode){
        if let name = geocode.placemark?.thoroughfare {
            SocketIOManager.Instance.setPetGPSlocationName(id: geocode.petId, name)
            NotificationManager.Instance.postPetGeoCodeUpdates(with: geocode)
        }
    }
    
}




































