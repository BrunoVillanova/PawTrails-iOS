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
    
    var zoomLevel: Int {
        let maxZoom: Double = 20
        let zoomScale = self.visibleMapRect.size.width / Double(self.frame.size.width)
        let zoomExponent = log2(zoomScale)
        return Int(maxZoom - ceil(zoomExponent))
    }
    
}

extension MKMapView {
    
    func addAnnotation(_ coordinate: CLLocationCoordinate2D, color: UIColor = UIColor.red){
        self.addAnnotation(MKLocation(id: MKLocationId(id: 0, type: .pet), coordinate: coordinate, color: color))
    }
    
    func setVisibleMapForAnnotations() {
        
        if self.annotations.count == 1 {
            self.centerOn(self.annotations.first!.coordinate)
        }else{
            let coordinates = self.annotations.map({ $0.coordinate })
            setVisibleMapFor(coordinates)
        }
    }
    
    func centerOn(_ location: CLLocationCoordinate2D, with regionRadius: CLLocationDistance = 100.0, animated: Bool = false){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        self.setRegion(check(region: coordinateRegion), animated: animated)
    }
    
    
    func check(region: MKCoordinateRegion) -> MKCoordinateRegion {
        var region = region
        if region.span.latitudeDelta > 180 { region.span.latitudeDelta = 180 }
        if region.span.longitudeDelta > 360 { region.span.longitudeDelta = 360 }
        return region
    }
    
    func fitMapViewToAnnotaionList(annotations: [PTAnnotation], animated: Bool = true) -> Void {
        let mapEdgePadding = UIEdgeInsets(top: 70, left: 30, bottom: 20, right: 30)
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<annotations.count {
            let annotation = annotations[index]
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        self.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: animated)
    }
    
    func setVisibleMapFor(_ coordinates: [CLLocationCoordinate2D ], padding: UIEdgeInsets = UIEdgeInsetsMake(UIScreen.main.bounds.height/10, UIScreen.main.bounds.width/10, UIScreen.main.bounds.height/5, UIScreen.main.bounds.width/10)) {

        var zoomRect = MKMapRectNull
        for i in coordinates {
            let point = MKMapPointForCoordinate(i)
            zoomRect = MKMapRectUnion(zoomRect, MKMapRectMake(point.x, point.y, 40, 40))
        }
        self.setVisibleMapRect(zoomRect, edgePadding: padding, animated: true)
    }
    
    func getZoom() -> Double {
        // function returns current zoom of the map
        var angleCamera = self.camera.heading
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = fabs(angleCamera - 180)
        }
        let angleRad = .pi * angleCamera / 180 // camera heading in radians
        let width = Double(self.frame.size.width)
        let height = Double(self.frame.size.height)
        let heightOffset : Double = 20 // the offset (status bar height) which is taken by MapKit into consideration to calculate visible area height
        // calculating Longitude span corresponding to normal (non-rotated) width
        let spanStraight = width * self.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return log2(360 * ((width / 256) / spanStraight)) + 1;
    }
    
    // Safe Zone
    

    static func minimumAltitude(for meters: CLLocationDistance) -> CLLocationDistance {
        let map = MKMapView()
        return map.getMinimumAltitude(for: meters)
    }
    
    func getMinimumAltitude(for meters: CLLocationDistance, coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()) -> CLLocationDistance {
        self.centerOn(coordinate, with: meters, animated: false)
        return self.camera.altitude
    }
    
    func load(with coordinate: CLLocationCoordinate2D, shape: Shape, into view: UIView, fenceSide: Double = 50, callback: ((Fence)-> Void)? = nil) {
        DispatchQueue.main.async {
//            self.addAnnotation(coordinate, color: UIColor.yellow)

            let region = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, fenceSide, fenceSide)
            let frame = self.convertRegion(region, toRectTo: view)
            let fence = Fence(frame: frame, shape: shape)
            self.add(fence)
            if let callback = callback { callback(fence) }
        }
    }
    
    func load(with center: CLLocationCoordinate2D, topCenter:CLLocationCoordinate2D, shape: Shape, into view: UIView, isBackground: Bool = false, callback: ((Fence?)-> Void)? = nil) {

//        self.addAnnotation(center, color: UIColor.yellow)
//        self.addAnnotation(topCenter)
        
        let radius = center.location.distance(from: topCenter.location) * 2.0
        
        self.centerOn(center, with: radius, animated: false)
        self.setOrientation(with: center, topCenter: topCenter, into: view)
        
        if isBackground {
            setFence(with: center, topCenter: topCenter, shape: shape, into: view, callback: callback)
        }else{
            DispatchQueue.main.async {
                self.setFence(with: center, topCenter: topCenter, shape: shape, into: view, callback: callback)
            }
        }
    }
    
    private func setFence(with center: CLLocationCoordinate2D, topCenter:CLLocationCoordinate2D, shape: Shape, into view: UIView, callback: ((Fence?)-> Void)? = nil){
        
        let centerPoint = self.convert(center, toPointTo: view)
        let topCenterPoint = self.convert(topCenter, toPointTo: view)
        
        if !centerPoint.isNaN && !topCenterPoint.isNaN {
            let fence = Fence(centerPoint, topCenterPoint, shape: shape)
            self.add(fence)
            if let callback = callback { callback(fence) }
            
        }else if let callback = callback {
            callback(nil)
        }
    }
    
    private func add(_ fence: Fence, delayed seconds: Int = 1){
            self.layer.addSublayer(fence.layer)
            self.layer.addSublayer(fence.line)
    }
    
    private func setOrientation(with center: CLLocationCoordinate2D, topCenter:CLLocationCoordinate2D, into view: UIView) {

        let centerPoint = self.convert(center, toPointTo: view)
        let topCenterPoint = self.convert(topCenter, toPointTo: view)
        let side = centerPoint.distance(to: topCenterPoint)
        let topCenterTargetPoint = CGPoint(x: centerPoint.x, y: centerPoint.y - CGFloat(side))
        let base = topCenterPoint.distance(to: topCenterTargetPoint)
        
        let angle = acos(Double(side.square + side.square - base.square)/(2 * side * side))
        let direction = topCenterPoint.x > topCenterTargetPoint.x ? 1.0 : -1.0
        self.setCamera(MKMapCamera.init(lookingAtCenter: self.camera.centerCoordinate, fromDistance: self.camera.altitude, pitch: 0, heading: direction * angle.toDegrees), animated: false)
    }
    
    func getRenderer(overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let render = MKCircleRenderer(circle: overlay)
            render.fillColor = UIColor.red.withAlphaComponent(0.5)
            return render
        }else if let overlay = overlay as? MKPolygon {
            let render = MKPolygonRenderer(overlay: overlay)
            render.fillColor = UIColor.red.withAlphaComponent(0.5)
            return render
        }
        return MKOverlayRenderer()
    }
    
    func getAnnotationView(annotation: MKAnnotation) -> MKAnnotationView? {
 
        if annotation is MKLocation {
            // Better to make this class property
            let annotationIdentifier = "mkl"
            
            var annotationView: MKAnnotationView?
            if let dequeuedAnnotationView = self.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
                annotationView = dequeuedAnnotationView
                annotationView?.annotation = annotation
            }
            else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            
            if let annotationView = annotationView {
                let mkl = annotation as! MKLocation
                
                // Annotation
                annotationView.canShowCallout = false
                annotationView.frame.size = CGSize(width: 20, height: 20)
                
                annotationView.circle()
                annotationView.backgroundColor = mkl.color
                annotationView.border(color: UIColor.white, width: 2.5)
                annotationView.clipsToBounds = false
            }
            return annotationView
        }
        return nil
    }
}

extension CLLocationCoordinate2D {
    
    public var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    public var isDefaultZero: Bool {
        return self.latitude == 0 && self.longitude == 0
    }
    
    public static var Cork: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 51.8969, longitude: 8.4863)
    }
    
    public static var CorkRandom: CLLocationCoordinate2D {
        
        let latitude = self.Cork.latitude
        let longitude = self.Cork.longitude
        let dLat = Double(arc4random() % 10000)/1000000.0
        let dLong = Double(arc4random() % 10000)/1000000.0
        return CLLocationCoordinate2D(latitude: latitude + dLat, longitude: longitude + dLong)
    }
    
    func translate(metersLat:Double, metersLong:Double) -> CLLocationCoordinate2D {
        
        var translatedCoordinate = CLLocationCoordinate2D()
        let region = MKCoordinateRegionMakeWithDistance(self, metersLat, metersLong)
        translatedCoordinate.latitude = self.latitude + region.span.latitudeDelta
        translatedCoordinate.longitude = self.longitude + region.span.longitudeDelta
        return translatedCoordinate
    }
    
    func getStreetName(handler: @escaping ((String?)->())) {
        CLGeocoder().reverseGeocodeLocation(self.location) { (placemarks, error) in
            handler(placemarks?.first?.name)
        }
    }
}

extension CLLocation {
    
    public var coordinateString: String {
        return "\(self.coordinate.latitude)-\(self.coordinate.longitude)"
    }
    
}

extension CGPoint {
    
    public var isNaN: Bool {
        return self.x.isNaN || self.y.isNaN
    }
    
}

extension Point {
    
    convenience init(coordinates: CLLocationCoordinate2D) {
        self.init(coordinates.latitude, coordinates.longitude)
    }
    
    public var coordinates: CLLocationCoordinate2D? {
        
        if let lat = latitude, let lon = longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            return nil
        }
    }
    
}

















































































    
