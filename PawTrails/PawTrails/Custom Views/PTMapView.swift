//
//  PTMapView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 07/11/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class PTMapView: MKMapView {

    let disposeBag = DisposeBag()
    var myAnnotations = [MKLocationId:[PTAnnotation]]()
    var myOverlays = [MKLocationId:MKOverlay]()
    var tripMode = false
    var firstTimeLoadingData = true
    var shouldFocusOnPets = false
    var activeTripsPetIDs = [Int]()
    let locationManager  = CLLocationManager()
    var alreadyFocusedOnUserLocation = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.showsScale = true
        self.showsUserLocation = true
        
        self.requestLocationAccess()
        
        DataManager.instance.getActivePetTrips().subscribe(onNext: { (trips) in
            
            if !self.tripMode {
                return
            }
            
            var petIDsOnTrips = Set<Int64>()
            trips.forEach({ (trip) in
                petIDsOnTrips.insert(trip.petId)
            })
            
            var latestTrips = [Trip]()
            
            for petIDonTrip in petIDsOnTrips {
                if let latestTrip = trips.filter({ (trip) -> Bool in
                    return trip.petId == petIDonTrip
                }).sorted (by: {$0.status < $1.status}).first {
                     latestTrips.append(latestTrip)
                }
            }
            
            self.activeTripsPetIDs = latestTrips.filter({ (trip) -> Bool in
                return trip.status < 2
            }).map{Int($0.petId)}
            
            for trip in latestTrips {
                
                let id = MKLocationId(id: Int(trip.petId), type: .pet)
                self.myAnnotations[id] = [PTAnnotation]()

                if let tripPoints = trip.points?.filter({ (tripPoint) -> Bool in
                    return tripPoint.point?.coordinates.latitude != 0 && tripPoint.point?.coordinates.longitude != 0
                }) {
                    for tripPoint in tripPoints {
                        let newAnnotation = PTAnnotation(tripPoint.point!.coordinates)
                        self.myAnnotations[id]?.append(newAnnotation)
                    }
                }
                
                self.drawOverlayForPetAnnotations(self.myAnnotations[id])
            }
        }).disposed(by: disposeBag)
            

        
        DataManager.instance.allPetDeviceData().subscribe(onNext: { (petDeviceDataList) in
            if let gpsUpdates = petDeviceDataList as [PetDeviceData]! {
                self.loadGpsUpdates(gpsUpdates)
            }

        }).disposed(by: disposeBag)
    }
    
    fileprivate func loadGpsUpdates(_ gpsUpdates: [PetDeviceData]?) {
        
        if let petsDevicesData = gpsUpdates as [PetDeviceData]!, petsDevicesData.count > 0 {
            
            for petDeviceData in petsDevicesData {
                
                self.load(petDeviceData)
                
                if self.activeTripsPetIDs.contains(petDeviceData.pet.id) {
                    let id = MKLocationId(id: Int(petDeviceData.pet.id), type: .pet)
                    if self.myAnnotations[id] != nil {
                        let newAnnotation = PTAnnotation(petDeviceData.deviceData.point.coordinates)
                        self.myAnnotations[id]?.append(newAnnotation)
                        self.drawOverlayForPetAnnotations(self.myAnnotations[id])
                        self.focusOnPet(petDeviceData.pet)
                    }
                }
                
                self.shouldFocusOnPets = (petDeviceData == petsDevicesData.last && firstTimeLoadingData)
            }
            
            if firstTimeLoadingData {
                firstTimeLoadingData = false
            }
            
            
            if shouldFocusOnPets {
                self.focusOnPets()
            }
        }
    }
    
    func load(_ petDeviceData: PetDeviceData) {
        
        
        let newAnnotation = PTAnnotation(petDeviceData)
        
        if let existingPetAnnotation = self.annotations.first(where: { ($0 is PTAnnotation) && ($0 as! PTAnnotation).petDeviceData?.pet.id == petDeviceData.pet.id }) as! PTAnnotation!
        {
            self.removeAnnotation(existingPetAnnotation)
        }
        
        self.addAnnotation(newAnnotation)
    }
    
    func drawOverlayForPetAnnotations(_ annotations: [PTAnnotation]?) {
        
        if let annotations = annotations as [PTAnnotation]!, annotations.count > 1 {
            var points = [CLLocationCoordinate2D]()
            points = annotations.map({ $0.coordinate })
            let polyline = MKPolyline(coordinates: points, count: points.count)
            self.add(polyline)
        }
    }
    
    func petAnnotationOnMap(pet: Pet) -> PTAnnotation? {
        if let existingPetAnnotation = self.annotations.first(where: { ($0 is PTAnnotation) && ($0 as! PTAnnotation).petDeviceData?.pet.id == pet.id }) as! PTAnnotation!
        {
            return existingPetAnnotation
        }
        return nil
    }
    
    func focusOnPets() {
        let coordinates = self.annotations.map({ $0.coordinate })
        if coordinates.count > 0 {
            self.setVisibleMapFor(coordinates)
        }
    }
    
    func focusOnPet(_ pet: Pet) {
        if let petAnnotationOnMap = petAnnotationOnMap(pet: pet) as PTAnnotation! {
            
            self.setVisibleMapFor([petAnnotationOnMap.coordinate])
            
//            let coordinates = petAnnotationOnMap.map({ $0.coordinate })
//            if coordinates.count > 0 {
//                self.setVisibleMapFor(coordinates)
//            }
            
//            self.centerOn(petAnnotationOnMap.coordinate, animated: true)
//            CATransaction.setCompletionBlock({
//                self.selectAnnotation(petAnnotationOnMap, animated: true)
//            })
        }
    }
    
    fileprivate func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .denied, .restricted:
            self.showAcessDeniedAlert()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    fileprivate func showAcessDeniedAlert() {
        let alertController = UIAlertController(title: "Location Accees Requested",
                                                message: "The location permission was not authorized. Please enable it in Settings to continue.",
                                                preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettings)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
}

//MARK: -
//MARK: MapView Delegate
extension PTMapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PTBasicAnnotationView.identifier) as? PTBasicAnnotationView
        
        if annotationView == nil {
            annotationView = PTBasicAnnotationView(annotation: annotation, reuseIdentifier: PTBasicAnnotationView.identifier)
            annotationView?.canShowCallout = false
        }
        
        annotationView?.configureWithAnnotation(annotation as! PTAnnotation)
        
        return annotationView
    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
        
        if let annotationView = view as? PTBasicAnnotationView {
            annotationView.showCallout()
            let petAnnotation = view.annotation as! PTAnnotation
            mapView.setCenter(petAnnotation.coordinate, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        if let annotationView = view as? PTBasicAnnotationView {
            annotationView.hideCallout()
        }

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKPolylineRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !(tripMode && alreadyFocusedOnUserLocation) {
            mapView.showAnnotations([userLocation], animated: true)
            alreadyFocusedOnUserLocation = true
        }
    }
}

private extension MKPolyline {
    convenience init(coordinates coords: Array<CLLocationCoordinate2D>) {
        let unsafeCoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: coords.count)
        unsafeCoordinates.initialize(from: coords, count: coords.count)
        self.init(coordinates: unsafeCoordinates, count: coords.count)
        unsafeCoordinates.deallocate(capacity: coords.count)
    }
}

enum pinType: Int {
    case pet = 0, safezone, pi
}

class MKLocationId: Hashable {
    var id: Int
    var type: pinType
    
    init(id : Int, type: pinType) {
        self.id = id
        self.type = type
    }
    
    var hashValue: Int {
        return id.hashValue ^ type.hashValue
    }
    
    static func == (lhs: MKLocationId, rhs: MKLocationId) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }
}

class MKLocation: MKPointAnnotation {
    
    var petDeviceData = PetDeviceData()
    var color:UIColor
    var id: MKLocationId
    
    init(id : MKLocationId, coordinate:CLLocationCoordinate2D, color: UIColor = UIColor.primary) {
        self.id = id
        self.color = color
        super.init()
        self.coordinate = coordinate
        
    }
    
    convenience init(_ petDeviceData: PetDeviceData, color: UIColor = UIColor.primary) {
        let coordinate = petDeviceData.deviceData.point.coordinates
        let id = MKLocationId(id:petDeviceData.pet.id, type: .pet)
        self.init(id: id, coordinate: coordinate, color: color)
        self.petDeviceData = petDeviceData
    }
    
    func move(coordinate:CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}

class PTAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var petDeviceData: PetDeviceData?
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    convenience init(_ petDeviceData: PetDeviceData) {
        let coordinate = petDeviceData.deviceData.point.coordinates
        self.init(coordinate)
        self.petDeviceData = petDeviceData
    }
    
    func move(coordinate:CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}

struct searchElement {
    var id: MKLocationId
    var object: Any
}

