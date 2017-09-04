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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.showsUserLocation = true
        
        
        
        
        petsCollectionView.delegate = self
        petsCollectionView.dataSource = self
        presenter.attachView(self)
        
        
        petsCollectionView.isHidden = true
        reloadPets()
        self.petsCollectionView.reloadData()
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.stopPetListUpdates()
        presenter.stopPetGPSUpdates()
    }
    
    
    
    // HomeView -- Mohamed
    
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
    
    
    
    // Mohamed: - MapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapView.getAnnotationView(annotation: annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation as? MKLocation {
            
            //            mapView.centerOn(annotation.coordinate, animated: true)
            
            switch annotation.id.type {
            case .pet:
                
                
                // need to be edited to be if let again
                
                if presenter.pets.first(where: { $0.id == annotation.id.id }) != nil {
                    
                    
                    //                    showPetDetails(pet)
                    
                    
                    // here accessories for annotation
                }
            default:
                break
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        focusOnPets()
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
            
            self.petsCollectionView.isHidden = true
            doubleTap = false
            
        } else {
            //First Tap
            self.petsCollectionView.isHidden = false
            doubleTap = true
        }
        
    }
    
    
    
    
    
    
    @IBAction func thirdButtonPressed(_ sender: Any) {
        
        self.mapView.setVisibleMapFor([self.mapView.userLocation.coordinate])
        
        
//        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
    }
    
    /// Mohamed - CollectionViewDataSource
    
    
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
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PetProfileTableViewController") as? PetProfileTableViewController {
                vc.pet = pet
                vc.fromMap = true
                nc.pushViewController(vc, animated: true)
                present(nc, animated: true, completion: nil)
            }
        }
    }
    
    // Mohamed - UicollectionViewDataSource..
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  presenter.pets.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = petsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PetsCollectionViewCell

        let pet = presenter.pets[indexPath.row]
        
        let image = pet.image
        
        if let image = image { cell.petImageCell?.image = UIImage(data: image) }
        
        return cell
    }
    
    
}



