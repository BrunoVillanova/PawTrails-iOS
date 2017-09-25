//
//  MapViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 04/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit




class MapViewController: UIViewController, HomeView, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var petsCollectionView: UICollectionView!
    @IBOutlet weak var firstButtonfromthebottom: UIButton!
    @IBOutlet weak var secButtonFromTheBottom: UIButton!
    @IBOutlet weak var thirdButtonFromTheBottom: UIButton!
    
    let locationManager = CLLocationManager()
    fileprivate let presenter = HomePresenter()
    fileprivate var annotations = [MKLocationId:MKLocation]()
    var selectedPet: Pet?
    
    var data = [searchElement]()

    var tripListArray = [TripList]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        firstButtonfromthebottom.contentHorizontalAlignment = .fill
        firstButtonfromthebottom.contentMode = .scaleToFill
        firstButtonfromthebottom.imageView?.contentMode = .scaleToFill

        
           locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        
        mapView.showsScale = false
        mapView.showsUserLocation = true
        petsCollectionView.delegate = self
        petsCollectionView.dataSource = self
        presenter.attachView(self)
        petsCollectionView.isHidden = true
        self.petsCollectionView.reloadData()
        reloadPets()
}
    

    func reloadPets(){
        presenter.getPets()
    }
    deinit {
        self.presenter.deteachView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.startPetsListUpdates()
        presenter.startPetsGPSUpdates { (id, point) in
            self.load(id: id, point: point)
        }

    }
    
    
    
    
    func showAlert() {
        if tripListArray.count > 0 {
            self.popUpDestructive(title: "Trip in progress", msg: "There is a trip already in progress, you can join it right now", cancelHandler: nil, proceedHandler: { (segue) in
            })
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.stopPetListUpdates()
        presenter.stopPetGPSUpdates()
    }
    
    
    
    // HomeView --
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func loadPets(){
        
        var petsIdsToRemove = annotations.map({ $0.key.id })
        
        for pet in presenter.pets {
            
            if let index = petsIdsToRemove.index(of: pet.id) {
                petsIdsToRemove.remove(at: index)
            }
            
            if let point = SocketIOManager.instance.getGPSData(for: pet.id)?.point {
                load(id: MKLocationId(id: pet.id, type: .pet), point: point)
            }
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

    func load(id: MKLocationId, point: Point){
        if self.annotations[id] == nil {
            self.startTracking(id, coordinate: point.coordinates, color: UIColor.primary)
        }else{
            self.updateTracking(id, coordinate: point.coordinates)
        }
        self.focusOnPets()
    }
    
    
    func startTracking(_ id: MKLocationId, coordinate:CLLocationCoordinate2D, color: UIColor) {
        self.annotations[id] = MKLocation(id: id, coordinate: coordinate, color: color)
        self.mapView.addAnnotation(self.annotations[id]!)
    }
    
    
    func updateTracking(_ id: MKLocationId, coordinate:CLLocationCoordinate2D) {
        self.annotations[id]?.move(coordinate:coordinate)
    }
    
    
    func stopPetTracking(_ id: Int){
        self.annotations.removeValue(forKey: MKLocationId(id:id, type: .pet))
    }
    
    
    func userNotSigned() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func noPetsFound() {
        alert(title: "", msg: "No pets found", type: .blue)
    }
    
    
    
    // MARK: - MapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapView.getAnnotationView(annotation: annotation)

    }
 
    

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation as? MKLocation {
  
            switch annotation.id.type {
            case .pet:
                if let pet = presenter.pets.first(where: { $0.id == annotation.id.id }) {
    
                 print(pet)
                    
                }
            default:
                break
            }
            
        }
    }
    
  
    
    func focusOnPets(){
        let coordinates = Array(self.annotations.values).filter({ $0.id.type == .pet && !$0.coordinate.isDefaultZero }).map({ $0.coordinate })
        mapView.setVisibleMapFor(coordinates)
    }
    
    
    
    @IBAction func firstButtonPressed(_ sender: Any) {
        print("firstButtonPressed")
    }
    
    
    var doubleTap : Bool! = false
    @IBAction func secButtonPressed(_ sender: Any) {

        
        if (doubleTap) {
            self.petsCollectionView.slideInAffect(direction: kCATransitionFromRight)
            self.petsCollectionView.isHidden = true
            doubleTap = false
        } else {
            self.petsCollectionView.slideInAffect(direction: kCATransitionFromLeft)
            self.petsCollectionView.isHidden = false
            doubleTap = true
        }
    }
    

    @IBAction func thirdButtonPressed(_ sender: Any) {
        self.mapView.setVisibleMapFor([self.mapView.userLocation.coordinate])
    }
    
    /// MARK - CollectionViewDataSource
    
    
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
    
    // MARK - UicollectionViewDataSource..

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  presenter.pets.count
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let pet = presenter.pets[indexPath.item]
       let element = (id: MKLocationId(id: pet.id, type: .pet), object: pet)
        if let coordinate = annotations[element.id]?.coordinate {
            mapView.centerOn(coordinate, animated: true)
            
        }

    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = petsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PetsCollectionViewCell

        let pet = presenter.pets[indexPath.item]
 
        let image = pet.image
        
        if let image = image { cell.petImageCell?.image = UIImage(data: image) }
        
        return cell
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
    
    
    let pet = Pet()
    var color:UIColor
    var id: MKLocationId

    
    init(id : MKLocationId, coordinate:CLLocationCoordinate2D, color: UIColor = UIColor.primary) {
        self.id = id
        self.color = color
        super.init()
        self.coordinate = coordinate
    }
    
    func move(coordinate:CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}


struct searchElement {
    var id: MKLocationId
    var object: Any
}



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


