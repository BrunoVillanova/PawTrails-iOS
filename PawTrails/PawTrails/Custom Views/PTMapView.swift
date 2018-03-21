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
import GSMessages

class PTMapView: MKMapView {

    let disposeBag = DisposeBag()
    var myAnnotations = [MKLocationId:[PTAnnotation]]()
    var myOverlays = [MKLocationId:MKOverlay]()
    var tripMode = false
    var firstTimeLoadingData = true
    var shouldFocusOnPets = false
    var activeTripsPetIDs = [Int]()
    var pausedTripsPetIDs = [Int]()
    let locationManager  = CLLocationManager()
    var alreadyFocusedOnUserLocation = false
    var alreadyFocusedOnPets = false
    var isStaticView = false
    var currentGpsMode: GPSTimeIntervalMode = .live
    var calloutDelegate: PTPetCalloutViewDelegate?
    var focusedPetID: Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    fileprivate func initialize() {
        self.delegate = self
        self.showsScale = true
        self.showsUserLocation = true
    
        self.requestLocationAccess()
    }
    
//    override func willMove(toWindow newWindow: UIWindow?) {
//        super.willMove(toWindow: newWindow)
//
//        if newWindow == nil {
//            // UIView disappear
//        } else {
//            // UIView appear
//        }
//    }
    
    func allowUserInteraction(_ enabled: Bool) {
        self.isZoomEnabled = enabled
        self.isScrollEnabled = enabled
        self.isUserInteractionEnabled = enabled
    }
    
    func setStaticTripView(_ trip: Trip) {
        self.showsUserLocation = false
        self.showsPointsOfInterest = false
        self.showsTraffic = false
        self.showsBuildings = false
        self.showsScale = false
        allowUserInteraction(true)
        
        if let tripAnnotations = self.drawOverlay(trip) {
            
            let annotationsWithPoint = tripAnnotations.filter({ (ann) -> Bool in
                return ann.tripPoint != nil && ann.tripPoint?.point != nil
            })
            
            if let firstAnnotation = annotationsWithPoint.first, let tripPoint = firstAnnotation.tripPoint {
                let newAnnotation = PTAnnotation(tripPoint, pet: trip.pet)
                newAnnotation.isStartingCoordinate = true
                self.addAnnotation(newAnnotation)
            }
            
            if let lastAnnotation = annotationsWithPoint.last, let tripPoint = lastAnnotation.tripPoint {
                let newAnnotation = PTAnnotation(tripPoint, pet: trip.pet)
                self.addAnnotation(newAnnotation)
            }
            
            fitMapViewToAnnotaionList(annotations: annotationsWithPoint, animated: false)
        }
        
    }
    
    func showGpsUpdates() {
        DataManager.instance.allPetDeviceData(currentGpsMode).subscribe(onNext: { (petDeviceDataList) in
            UIApplication.shared.keyWindow?.rootViewController!.hideMessage()
            if let gpsUpdates = petDeviceDataList as [PetDeviceData]! {
                self.loadGpsUpdates(gpsUpdates)
            }
            
        }).disposed(by: disposeBag)
    }
    
    fileprivate func drawOverlay(_ trip: Trip?) -> [PTAnnotation]? {
    
        if let trip = trip, let tripPoints = trip.points, tripPoints.count > 0  {
            let id = MKLocationId(id: Int(trip.petId), type: .pet)
            self.myAnnotations[id] = [PTAnnotation]()
            
            tripPoints.forEach({ (tripPoint) in
                let newAnnotation = PTAnnotation(tripPoint, pet: trip.pet)
                self.myAnnotations[id]?.append(newAnnotation)
            })
            self.drawOverlayForPetAnnotations(self.myAnnotations[id])
            
            return self.myAnnotations[id]
        }
        
        return nil
    }
    
    func startTripMode() {
        
        if tripMode {
            return
        }
        
        tripMode = true
        
        DataManager.instance.getActivePetTrips().subscribe(onNext: { (trips) in
            
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
                return trip.status == 0
            }).map{Int($0.petId)}
            
            self.pausedTripsPetIDs = latestTrips.filter({ (trip) -> Bool in
                return trip.status == 1
            }).map{Int($0.petId)}
            
            latestTrips.forEach({ (trip) in
                let _ = self.drawOverlay(trip)
            })

        }).disposed(by: disposeBag)
        
        self.showGpsUpdates()
    }
    
    fileprivate func loadGpsUpdates(_ gpsUpdates: [PetDeviceData]?) {
        
        if let petsDevicesData = gpsUpdates, petsDevicesData.count > 0 {
            
            for petDeviceData in petsDevicesData {
                
                self.load(petDeviceData)
                
                if self.activeTripsPetIDs.contains(petDeviceData.pet.id) && !self.pausedTripsPetIDs.contains(petDeviceData.pet.id) && tripMode {
                    let id = MKLocationId(id: Int(petDeviceData.pet.id), type: .pet)
                    if self.myAnnotations[id] != nil {
                        if let point = petDeviceData.deviceData.point, let coords = point.coordinates {
                            let newAnnotation = PTAnnotation(coords)
                            self.myAnnotations[id]?.append(newAnnotation)
                            self.drawOverlayForPetAnnotations(self.myAnnotations[id])
                            //self.focusOnPet(petDeviceData.pet)
                        }
                    }
                }
                
                self.shouldFocusOnPets = (petDeviceData == petsDevicesData.last && firstTimeLoadingData)
            }
            
            if firstTimeLoadingData {
                firstTimeLoadingData = false
            }
            
            shouldFocusOnPets  = true
            if shouldFocusOnPets {
                alreadyFocusedOnPets = true
                self.focusOnPets()
            } else if let focusedPetID = focusedPetID, let petAnnotationOnMap = petAnnotationOnMap(focusedPetID) as PTAnnotation!{
                let coordinate = petAnnotationOnMap.coordinate
                if CLLocationCoordinate2DIsValid(coordinate) && coordinate.latitude != 0 && coordinate.longitude != 0 {
                    self.setVisibleMapFor([petAnnotationOnMap.coordinate])
                }
            }
        }
    }
    
    func load(_ petDeviceData: PetDeviceData) {
        
        if let existingPetAnnotation = self.annotations.first(where: { ($0 is PTAnnotation) && ($0 as! PTAnnotation).petDeviceData?.pet.id == petDeviceData.pet.id }) as! PTAnnotation!
        {
            self.removeAnnotation(existingPetAnnotation)
        }
        
        
        if petDeviceData.deviceData.point != nil {
            let newAnnotation = PTAnnotation(petDeviceData)
            self.addAnnotation(newAnnotation)
        }
    }
    
    func drawOverlayForPetAnnotations(_ annotations: [PTAnnotation]?) {
        
        if let annotations = annotations as [PTAnnotation]!, annotations.count > 1 {
            var points = [CLLocationCoordinate2D]()
            
            annotations.forEach({ (annotation) in
                if let tripPoint = annotation.tripPoint {
                    if tripPoint.status == .running {
                        // We dont need to draw since the trip starting point coordinate because we will add a DonutCallout for it
                        if !annotation.isStartingCoordinate {
                           points.append(annotation.coordinate)
                        } else {
                            print("aqui")
                        }
                    } else {
                        if points.count > 0 {
                            let polyline = MKPolyline(coordinates: points, count: points.count)
                            self.add(polyline)
                        }
                        points = [CLLocationCoordinate2D]()
                    }
                } else {
                    points.append(annotation.coordinate)
                    let polyline = MKPolyline(coordinates: points, count: points.count)
                    self.add(polyline)
                }
            })
        }
    }
    
    func petAnnotationOnMap(pet: Pet) -> PTAnnotation? {
        return petAnnotationOnMap(pet.id)
    }
    
    func petAnnotationOnMap(_ petID: Int) -> PTAnnotation? {
        if let existingPetAnnotation = self.annotations.first(where: {
            ($0 is PTAnnotation) && ($0 as! PTAnnotation).petDeviceData?.pet.id == petID
        }) as! PTAnnotation! {
            
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
            let coordinate = petAnnotationOnMap.coordinate
            if CLLocationCoordinate2DIsValid(coordinate) && coordinate.latitude != 0 && coordinate.longitude != 0 {
                self.setVisibleMapFor([petAnnotationOnMap.coordinate])
                focusedPetID = pet.id
            }
            else {
                showLocationUnavailableAlert()
            }
        } else {
            showLocationUnavailableAlert()
        }
    }
    
    fileprivate func showLocationUnavailableAlert() {
        // the pet is not even in the map yet
        let alert = UIAlertController(title: "Location unavailable", message: "Move your device outdoors to get your first location", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .denied, .restricted:
            self.showAccessDeniedAlert()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    fileprivate func showAccessDeniedAlert() {
        let alertController = UIAlertController(title: "Location Access Requested",
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
        
        
        if let annotation = annotation as? PTAnnotation {
            var annotationView: MKAnnotationView?
            
            if annotation.isStartingCoordinate {
                
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PTDonutAnnotationView.identifier) as? PTDonutAnnotationView
                
                if annotationView == nil {
                    annotationView = PTDonutAnnotationView(annotation: annotation, reuseIdentifier: PTDonutAnnotationView.identifier)
                }
                
            } else {
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PTBasicAnnotationView.identifier) as? PTBasicAnnotationView
            
                if annotationView == nil {
                    annotationView = PTBasicAnnotationView(annotation: annotation, reuseIdentifier: PTBasicAnnotationView.identifier)
                }
                
                if let annotationView = annotationView as? PTBasicAnnotationView {
                    annotationView.canShowCallout = false
                    
                    if let calloutDelegate = calloutDelegate {
                        annotationView.calloutDelegate = calloutDelegate
                    }
                    
                    annotationView.configureWithAnnotation(annotation)
                
                }
                
            }
            
            return annotationView
        }
        
        return nil

    }
    
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
            polylineRenderer.strokeColor = PTConstants.colors.primary
            polylineRenderer.lineWidth = 2.3
            return polylineRenderer
        }
        return MKPolylineRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if (!tripMode && !alreadyFocusedOnUserLocation) {
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
        
        let id = MKLocationId(id: petDeviceData.pet.id, type: .pet)
        
        if let point = petDeviceData.deviceData.point, let coords = point.coordinates {
            self.init(id: id, coordinate: coords, color: color)
        } else {
            self.init(id: id, coordinate: CLLocationCoordinate2D(), color: color)
        }

        self.petDeviceData = petDeviceData
    }
    
    func move(coordinate:CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}

class PTAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var petDeviceData: PetDeviceData?
    var pet: Pet?
    var isStartingCoordinate: Bool = false
    var tripPoint: TripPoint?
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    convenience init(_ coordinate: CLLocationCoordinate2D, pet: Pet) {
        self.init(coordinate)
        self.pet = pet
    }
    
    convenience init(_ tripPoint: TripPoint, pet: Pet) {
        self.init(CLLocationCoordinate2D())
        self.tripPoint = tripPoint
        self.pet = pet
        
        if let point = tripPoint.point, let coords = point.coordinates {
            self.coordinate.latitude = coords.latitude
            self.coordinate.longitude = coords.longitude
        }
    }
    
    convenience init(_ petDeviceData: PetDeviceData) {
        
        if let point = petDeviceData.deviceData.point, let coords = point.coordinates {
            self.init(coords)
        } else {
            self.init(CLLocationCoordinate2D())
        }
        
        self.petDeviceData = petDeviceData
        self.pet = petDeviceData.pet
    }
    
    func move(coordinate:CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}

struct searchElement {
    var id: MKLocationId
    var object: Any
}

