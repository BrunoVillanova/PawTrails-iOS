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
        self.addAnnotation(MKLocation(title: "", lat: coordinate.latitude, long: coordinate.longitude, color: color))
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
        self.setRegion(coordinateRegion, animated: animated)
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
    
    func load(with coordinate: CLLocationCoordinate2D, isCircle: Bool, into view: UIView, fenceSide: Double = 50) -> Fence {
        let region = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, fenceSide, fenceSide)
        let frame = self.convertRegion(region, toRectTo: view)
        let fence = Fence(frame: frame, isCircle: isCircle)
        add(fence)
        return fence
    }
    
    func load(with center: CLLocationCoordinate2D, topCenter:CLLocationCoordinate2D, isCircle: Bool, into view: UIView, paintShapes: Bool = false) -> Fence {

//        self.addAnnotation(center, color: UIColor.yellow)
//        self.addAnnotation(topCenter)
        
        let radius = center.location.distance(from: topCenter.location) * 2
        
        self.centerOn(center, with: radius, animated: false)
        setOrientation(with: center, topCenter: topCenter, into: view)
        
        let centerPoint = self.convert(center, toPointTo: view)
        let topCenterPoint = self.convert(topCenter, toPointTo: view)
        
        let fence = Fence(centerPoint, topCenterPoint, isCircle: isCircle)
        
        if paintShapes {
            if isCircle {
                let circle = MKCircle(center: center, radius: center.location.distance(from: topCenter.location))
                add(circle)
            }else{
                
                let p1 = self.convert(CGPoint.init(x: fence.x0, y: fence.y0), toCoordinateFrom: view)
                let p2 = self.convert(CGPoint.init(x: fence.xf, y: fence.y0), toCoordinateFrom: view)
                let p3 = self.convert(CGPoint.init(x: fence.xf, y: fence.yf), toCoordinateFrom: view)
                let p4 = self.convert(CGPoint.init(x: fence.x0, y: fence.yf), toCoordinateFrom: view)
                
                let poligon = MKPolygon(coordinates: [p1, p2, p3, p4], count: 4)
                add(poligon)
            }
        }else{
            add(fence)
        }
        
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
    
    static func getSnapShot(with center: CLLocationCoordinate2D, topCenter: CLLocationCoordinate2D, isCircle: Bool, into view: UIView, delegate: MKMapViewDelegate, handler: @escaping ((UIImage?)->())){
        let mapView = MKMapView(frame: view.frame)
        let camera = mapView.camera
        camera.pitch = 0.0
        mapView.setCamera(camera, animated: false)
        _ = mapView.load(with: center, topCenter: topCenter, isCircle: isCircle, into: view)
        
        let circle = MKCircle(center: center, radius: center.location.distance(from: topCenter.location))
        mapView.add(circle)
        
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.scale = UIScreen.main.scale
        options.size = mapView.frame.size
        options.mapType = .satellite
        options.showsBuildings = true
        options.showsPointsOfInterest = true
        options.camera = mapView.camera
        
        let shotter = MKMapSnapshotter(options: options)
        shotter.start(completionHandler: { (snapshot, error) in
            if error == nil, let snapshot = snapshot {
                handler(snapshot.image)
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
}

extension CLLocationCoordinate2D {
    
    public var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    public var isDefaultZero: Bool {
        return self.latitude == 0 && self.longitude == 0
    }
    
    /*
     -(CLLocationCoordinate2D)translateCoord:(CLLocationCoordinate2D)coord MetersLat:(double)metersLat MetersLong:(double)metersLong{
     
     CLLocationCoordinate2D tempCoord;
     
     MKCoordinateRegion tempRegion = MKCoordinateRegionMakeWithDistance(coord, metersLat, metersLong);
     MKCoordinateSpan tempSpan = tempRegion.span;
     
     tempCoord.latitude = coord.latitude + tempSpan.latitudeDelta;
     tempCoord.longitude = coord.longitude + tempSpan.longitudeDelta;
     
     return tempCoord;
     
     }
     
     */
    
    func translate(metersLat:Double, metersLong:Double) -> CLLocationCoordinate2D {
        
        var translatedCoordinate = CLLocationCoordinate2D()
        let region = MKCoordinateRegionMakeWithDistance(self, metersLat, metersLong)
        translatedCoordinate.latitude = self.latitude + region.span.latitudeDelta
        translatedCoordinate.longitude = self.longitude + region.span.longitudeDelta
        return translatedCoordinate
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

















































































    
