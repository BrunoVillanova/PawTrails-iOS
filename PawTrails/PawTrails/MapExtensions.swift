//
//  MapExtensions.swift
//  PawTrails
//
//  Created by Marc Perello on 29/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import CoreLocation
import MapKit


extension MKMapView {
    
    func setVisibleMapForAnnotations() {
        
        if self.annotations.count == 1 {
            self.centerOn(self.annotations.first!.coordinate)
        }else{
            var zoomRect = MKMapRectNull
            for i in self.annotations {
                let point = MKMapPointForCoordinate(i.coordinate)
                zoomRect = MKMapRectUnion(zoomRect, MKMapRectMake(point.x, point.y, 20, 20))
            }
            self.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(UIScreen.main.bounds.height/10, UIScreen.main.bounds.width/10, UIScreen.main.bounds.height/5, UIScreen.main.bounds.width/10), animated: true)
        }
        
    }
    
    func centerOn(_ location: CLLocationCoordinate2D, with regionRadius: CLLocationDistance = 100.0, animated: Bool = false){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0,regionRadius * 2.0)
        self.setRegion(coordinateRegion, animated: animated)
    }
}

extension CLLocationCoordinate2D {
    
    public var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    public var isDefaultZero: Bool {
        return self.latitude == 0 && self.longitude == 0
    }
    
}

