//
//  MapViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 04/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var petsCollectionView: UICollectionView!
    @IBOutlet weak var firstButtonfromthebottom: UIButton!
    @IBOutlet weak var secButtonFromTheBottom: UIButton!
    @IBOutlet weak var thirdButtonFromTheBottom: UIButton!
    
    var locationManager : CLLocationManager?
    fileprivate let presenter = HomePresenter()
    fileprivate var annotations = [MKLocationId:PTAnnotation]()
    var selectedPet: Pet?
    var data = [searchElement]()
    var tripListArray = [TripList]()
    var focusedOnPetsOnViewAppears = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let disposeBag = DisposeBag()
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        firstButtonfromthebottom.contentHorizontalAlignment = .fill
        firstButtonfromthebottom.contentMode = .scaleToFill
        firstButtonfromthebottom.imageView?.contentMode = .scaleToFill
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.startUpdatingLocation()
        }
        
        mapView.showsScale = false
        mapView.showsUserLocation = true
        petsCollectionView.delegate = self
        petsCollectionView.dataSource = self
        petsCollectionView.reloadData()
        petsCollectionView.isHidden = true
        
        presenter.attachView(self)
        reloadPets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        presenter.startPetsListUpdates()
//        presenter.startPetsGPSUpdates { (id, point) in
////            self.load(id: id, point: point)
////            self.load(p)
//        }
//
//        loadPets()
        getRunningandPausedTrips()
        
        appDelegate.socketReactive?.on("gpsUpdates").subscribe(onNext: { (data) in
            print("gpsUpdates")
            
            if let json = data.first as? [Any] {
                for petDeviceDataObject in json {
                    if let petDeviceDataJson = petDeviceDataObject as? [String:Any] {
                        let petDeviceData = PetDeviceData(petDeviceDataJson)
                        self.load(petDeviceData)
                    }
                }
                
                if (!self.focusedOnPetsOnViewAppears && json.count == self.annotations.count) {
                    self.focusOnPets()
                    self.focusedOnPetsOnViewAppears = true
                }
            } else{
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", data)
            }
            
        }){}.addDisposableTo(disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.stopPetListUpdates()
        presenter.stopPetGPSUpdates()
    }
    
    func reloadPets(){
        presenter.getPets()
    }
    
    deinit {
        self.presenter.deteachView()
    }
    
    func getRunningandPausedTrips() {
        tripListArray.removeAll()
        APIRepository.instance.getTripList([0,1]) { (error, trips) in
            if error != nil {
                print("error zf dsf sdf \(String(describing: error?.localizedDescription))")
            } else {
                if let trips = trips, trips.isEmpty == false {
                    
                    print("error zf dsf sdf \(trips)")
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
                    gestureRecognizer.delegate = self
                    
                    
                    for trip in trips {
                        self.tripListArray.append(trip)
                    }
                    
                    self.alertwithGeature(title: "", msg: "ADVENTURE IN PROGRESS, CLICK TO RESUME", type: .red, disableTime: 150, geatureReconginzer: gestureRecognizer, handler: {
                    })
                }
            }
        }
    }
    
    // HomeView --
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func load(_ petDeviceData: PetDeviceData) {
        let id = MKLocationId(id: petDeviceData.pet.id, type: .pet)
        if self.annotations[id] == nil {
            self.startTracking(petDeviceData, color: UIColor.primary)
        }else{
            self.updateTracking(petDeviceData)
        }
    }
    
    func startTracking(_ petDeviceData: PetDeviceData, color: UIColor) {
        let id = MKLocationId(id: petDeviceData.pet.id, type: .pet)
        self.annotations[id] = PTAnnotation(petDeviceData)
        self.mapView.addAnnotation(self.annotations[id]!)
    }
    
    func updateTracking(_ petDeviceData: PetDeviceData) {
        let id = MKLocationId(id: petDeviceData.pet.id, type: .pet)
        let coordinate = petDeviceData.deviceData.coordinates.coordinates
        self.annotations[id]?.move(coordinate:coordinate)
    }
    
//    func load(id: MKLocationId, point: Point){
//        if self.annotations[id] == nil {
//            self.startTracking(id, coordinate: point.coordinates, color: UIColor.primary)
//        }else{
//            self.updateTracking(id, coordinate: point.coordinates)
//        }
//    }
    
//    func startTracking(_ id: MKLocationId, coordinate:CLLocationCoordinate2D, color: UIColor) {
//        self.annotations[id] = MKLocation(id: id, coordinate: coordinate, color: color)
//        self.mapView.addAnnotation(self.annotations[id]!)
//    }
    
    func updateTracking(_ id: MKLocationId, coordinate:CLLocationCoordinate2D) {
        self.annotations[id]?.move(coordinate:coordinate)
    }
    
    func stopPetTracking(_ id: Int){
        self.annotations.removeValue(forKey: MKLocationId(id:id, type: .pet))
    }
    
    func focusOnPets(){
        let coordinates = Array(self.annotations.values).filter({ $0.petDeviceData != nil && !$0.coordinate.isDefaultZero }).map({ $0.coordinate })
        if coordinates.count > 0 {
            mapView.setVisibleMapFor(coordinates)
        }
    }
    
    @IBAction func firstButtonPressed(_ sender: Any) {
        hideNotification()
        if tripListArray.isEmpty == true   {
            performSegue(withIdentifier: "startAdventue", sender: nil)
        } else {
            performSegue(withIdentifier: "adventrueInProgress", sender: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adventrueInProgress" {
            let destinationController = segue.destination as! UINavigationController
            let targetController = destinationController.topViewController as! TripScreenViewController
            for trip in tripListArray {
                targetController.tripIds.append(trip.id)
            }
            
        }
    }
    
    @IBAction func secButtonPressed(_ sender: Any) {
        if (!self.petsCollectionView.isHidden) {
            self.petsCollectionView.slideInAffect(direction: kCATransitionFromLeft)
            self.petsCollectionView.isHidden = true
        } else {
            self.petsCollectionView.slideInAffect(direction: kCATransitionFromRight)
            self.petsCollectionView.isHidden = false
        }
    }
    
    @IBAction func thirdButtonPressed(_ sender: Any) {
        self.mapView.setVisibleMapFor([self.mapView.userLocation.coordinate])
    }
    
    func presentPet(_ pet: Pet, activityEnabled:Bool = false) {
        
        let nc = UINavigationController()
        
        if activityEnabled {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PetActivityViewController") as? PetActivityViewController {
                vc.pet = pet
                vc.fromMap = true
                nc.pushViewController(vc, animated: true)
                present(nc, animated: true, completion: nil)
            }
        }else{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PetProfileCollectionViewController") as? PetProfileCollectionViewController {
                vc.pet = pet
                vc.fromMap = true
                nc.pushViewController(vc, animated: true)
                present(nc, animated: true, completion: nil)
            }
        }
    }
}

//MARK: HomeView
extension MapViewController: HomeView {
    func loadPets(){
        var petsIdsToRemove = annotations.map({ $0.key.id })
        for pet in presenter.pets {
            if let index = petsIdsToRemove.index(of: pet.id) {
                petsIdsToRemove.remove(at: index)
            }
//            if let point = SocketIOManager.instance.getGPSData(for: pet.id)?.point {
//                load(id: MKLocationId(id: pet.id, type: .pet), point: point)
//            }
        }
        for id in petsIdsToRemove {
            if let annotationToRemove = annotations.removeValue(forKey: MKLocationId(id: id, type: .pet)) {
                mapView.removeAnnotation(annotationToRemove)
            }
        }
        focusOnPets()
    }
    
    func reload() {
        
    }
    
    func userNotSigned() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func noPetsFound() {
        alert(title: "", msg: "No pets found", type: .blue)
    }
}

//MARK: GestureRecognizer Delegate
extension MapViewController: UIGestureRecognizerDelegate {
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        self.performSegue(withIdentifier: "adventrueInProgress", sender: nil)
        self.hideNotification()
    }
}

//MARK: CollectionView DataSource
extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  presenter.pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = petsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PetsCollectionViewCell
        let pet = presenter.pets[indexPath.item]
        if let image = pet.image {
            cell.petImageCell?.image = UIImage(data: image)
        }
        return cell
    }
}

//MARK: CollectionView Delegate
extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pet = presenter.pets[indexPath.item]
        let element = (id: MKLocationId(id: pet.id, type: .pet), object: pet)
        if let coordinate = annotations[element.id]?.coordinate {
            mapView.centerOn(coordinate, animated: true)
        }
    }
}

//MARK: -
//MARK: MapView Delegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PTBasicAnnotationView.identifier) as? PTBasicAnnotationView

        if annotationView == nil {
            annotationView = PTBasicAnnotationView(annotation: annotation, reuseIdentifier: PTBasicAnnotationView.identifier)
            annotationView?.canShowCallout = false
        }
        
        
        if !(annotation is MKUserLocation) {
            annotationView!.configureWithAnnotation(annotation as! PTAnnotation)
        }
        
        return annotationView
//
//
//        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PTBasicAnnotationView.identifier) {
//            annotationView = dequeuedAnnotationView
//            annotationView?.annotation = annotation
//        }
//
//        // Don't want to show a custom image if the annotation is the user's location.
//        guard !(annotation is MKUserLocation) else {
//            return nil
//        }
//
//        // Better to make this class property
//        let annotationIdentifier = "AnnotationIdentifier"
//
//        var annotationView: MKAnnotationView?
//        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
//            annotationView = dequeuedAnnotationView
//            annotationView?.annotation = annotation
//        }
//        else {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//
//        if let annotationView = annotationView {
//            // Configure your annotation view here
//            annotationView.canShowCallout = true
//            annotationView.image = UIImage(named: "yourImage")
//        }
//
////        return annotationView
//        return mapView.getAnnotationView(annotation: annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
        
        let petAnnotation = view.annotation as! PTAnnotation
        let views = Bundle.main.loadNibNamed("PTPetCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! PTPetCalloutView
        calloutView.configureWithAnnotation(petAnnotation)
        calloutView.center = CGPoint(x: (view.bounds.size.width / 2) + 46, y: -calloutView.bounds.size.height*0.42)
        view.addSubview(calloutView)
        mapView.setCenter(petAnnotation.coordinate, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: PTBasicAnnotationView.self) {
            for subview in view.subviews {
                if subview.isKind(of: PTPetCalloutView.self) {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}

//MARK: LocationManager Delegate
extension MapViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.last! as CLLocation
//
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//
//        self.mapView.setRegion(region, animated: true)
//    }
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
        let coordinate = petDeviceData.deviceData.coordinates.coordinates
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
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    convenience init(_ petDeviceData: PetDeviceData) {
        let coordinate = petDeviceData.deviceData.coordinates.coordinates
        self.init(coordinate: coordinate)
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

//MARK: View Animations
extension UIView {
    // Name this function in a way that makes sense to you...
    // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideInAffect(duration: TimeInterval = 1.0, completionDelegate: AnyObject? = nil, direction: String) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = delegate as? CAAnimationDelegate
        }
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = direction
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
}