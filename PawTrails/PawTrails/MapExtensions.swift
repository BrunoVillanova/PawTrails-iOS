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
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0,regionRadius * 2.0)
        self.setRegion(check(region: coordinateRegion), animated: animated)
    }
    
    func check(region: MKCoordinateRegion) -> MKCoordinateRegion {
        var region = region
        if region.span.latitudeDelta > 180 { region.span.latitudeDelta = 180 }
        if region.span.longitudeDelta > 360 { region.span.longitudeDelta = 360 }
        return region
    }
    
    func setVisibleMapFor(_ coordinates: [CLLocationCoordinate2D ]) {

        var zoomRect = MKMapRectNull
        for i in coordinates {
            let point = MKMapPointForCoordinate(i)
            zoomRect = MKMapRectUnion(zoomRect, MKMapRectMake(point.x, point.y, 20, 20))
        }
        self.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(UIScreen.main.bounds.height/10, UIScreen.main.bounds.width/10, UIScreen.main.bounds.height/5, UIScreen.main.bounds.width/10), animated: true)
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
    
    func load(with coordinate: CLLocationCoordinate2D, shape: Shape, into view: UIView, fenceSide: Double = 50) -> Fence {
        let region = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, fenceSide, fenceSide)
        let frame = self.convertRegion(region, toRectTo: view)
        let fence = Fence(frame: frame, shape: shape)
        add(fence)
        return fence
    }
    
    func load(with center: CLLocationCoordinate2D, topCenter:CLLocationCoordinate2D, shape: Shape, into view: UIView, paintShapes: Bool = false) -> Fence {

//        self.addAnnotation(center, color: UIColor.yellow)
//        self.addAnnotation(topCenter)
        
        let radius = center.location.distance(from: topCenter.location) * 2.0
        
        self.centerOn(center, with: radius, animated: false)
        setOrientation(with: center, topCenter: topCenter, into: view)
        
        let centerPoint = self.convert(center, toPointTo: view)
        let topCenterPoint = self.convert(topCenter, toPointTo: view)
        
        let fence = Fence(centerPoint, topCenterPoint, shape: shape)
        
        add(fence)
        
        return fence
    }
    
    private func add(_ fence: Fence){
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
    
    // Create SnapShot
    
    static func getSnapShot(with center: CLLocationCoordinate2D, topCenter: CLLocationCoordinate2D, shape: Shape, into view: UIView, handler: @escaping ((UIImage?)->())){
        
        let mapView = MKMapView(frame: view.frame)
        let camera = mapView.camera
        camera.pitch = 0.0
        mapView.setCamera(camera, animated: false)
        
        _ = mapView.load(with: center, topCenter: topCenter, shape: shape, into: view, paintShapes: true)
        
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.scale = UIScreen.main.scale
//        options.size = mapView.frame.size
        options.size = CGSize(width: 375, height: 200)
        options.mapType = .satellite
        options.showsBuildings = true
        options.showsPointsOfInterest = true
        options.camera = mapView.camera
        
        let shotter = MKMapSnapshotter(options: options)
        shotter.start(/*with: DispatchQueue.global(), */completionHandler: { (snapshot, error) in
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
            }else{
                handler(nil)
            }
        })

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

extension Point {
    
    convenience init(coordinates: CLLocationCoordinate2D) {
        self.init(coordinates.latitude, coordinates.longitude)
    }
    
    public var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}

















































































    
