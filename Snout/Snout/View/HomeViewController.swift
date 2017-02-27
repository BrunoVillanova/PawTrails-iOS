//
//  HomeViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController, HomeView, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UIViewControllerPreviewingDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var bottomConstraintBlurView: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSurnameLabel: UILabel!
    @IBOutlet weak var actionBlurView: UIVisualEffectView!

    fileprivate let locationManager = CLLocationManager()
    fileprivate var isLocating = false
    
    fileprivate let presenter = HomePresenter()
    
    fileprivate let closed:CGFloat = -170.0
    fileprivate let opened:CGFloat = -40.0
    
    fileprivate var pets = [_pet]()
    fileprivate var user:User!

    struct _pet {
        var name:String
        var location:(lat:Double,long:Double)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.actionBlurView.round()
        self.blurView.round(radius: 20)
        self.presenter.attachView(self)
        mapView.showsScale = false
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: view)
        }
        SocketIOManager.Instance.establishConnection()
        blurView(.open, animated: false)
    }
    
    deinit {
        self.presenter.deteachView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.presenter.checkSignInStatus()
//        if self.bottomConstraintBlurView.constant == self.opened {
//            blurView(.close)
//        }
    }
    
    @IBAction func handleLongPressure(_ sender: UILongPressGestureRecognizer) {
        if let indexPath = collectionView.indexPathForItem(at: sender.location(in: collectionView)) {
            if indexPath.section == 0 {
                if let vc = storyboard?.instantiateViewController(withIdentifier: "PetProfileViewController") as? PetProfileViewController {
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        let y = sender.translation(in: self.view).y / 2.5
        if (y < 0 && bottomConstraintBlurView.constant > opened) || (y > 0 && bottomConstraintBlurView.constant < closed) {
            bottomConstraintBlurView.constant += y
        }
        
        if sender.state == .ended {
            let action: blurViewAction = y < 0 ? .open : .close
            blurView(action, speed: 0.5)
        }
    }

    @IBAction func changeMapInfo(_ sender: UIButton) {
//        mapView.mapType = mapView.mapType == MKMapType.standard ? MKMapType.satellite : MKMapType.standard
        SocketIOManager.Instance.launch(name: "try")
        var annotation:MKPointAnnotation? = nil
        SocketIOManager.Instance.listen(name: "try") { (lat, long) in
            print(lat,long)
            if annotation == nil {
                annotation = MKPointAnnotation()
                self.add(annotation: annotation!, title: "try", lat: lat, long: long)
            }else{
                self.move(annotation: annotation!, lat: lat, long: long)
            }
        }

    }
    
    @IBAction func locationAction(_ sender: UIButton) {
        if !mapView.showsUserLocation {
            checkAuthorizationStatus()
            mapView.showsUserLocation = true
            centerMapOnLocation(mapView.userLocation.coordinate)
        }else{
            mapView.showsUserLocation = false
        }
    }
    
    // MARK: - HomeView
    
    func errorMessage(_ error: errorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func userNotSignedIn() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func plotPoint(latitude:Double, longitude:Double) {
    }
    
    func checkLocationAuthorization() {
        checkAuthorizationStatus()
    }
    
    func reload(_ user: User, _ pets: [Pet]) {
        self.user = user
        //        self.pets = pets
        self.userNameLabel.text = user.name
        self.userSurnameLabel.text = user.surname
        self.pets = [_pet]()

        self.pets.append(_pet(name: "La Rochelle", location: (lat:46.14939437647686, long:-1.142578125)))
        self.pets.append(_pet(name: "Mallorca", location: (lat:39.56335316582929, long:2.691650390625)))
        self.pets.append(_pet(name: "Nashville", location: (lat:36.1626638, long:-86.78160159999999)))
        self.pets.append(_pet(name: "Honolulu", location: (lat:21.3069444, long:-157.85833330000003)))
        self.pets.append(_pet(name: "Melbourne", location: (lat:-37.81361100000001, long:144.96305600000005)))

        self.collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? pets.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! petCell
        cell.circle()
        if indexPath.section == 0 {
            cell.imageView.backgroundColor = UIColor.lightGray
            cell.imageView.image = UIImage()
        }else{
            cell.imageView.backgroundColor = blueSystem
            cell.imageView.image = UIImage(named: "add")
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let pet = self.pets[indexPath.row]
            addAnnotation(title: pet.name, lat: pet.location.lat, long: pet.location.long)
        }else if indexPath.section == 1 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AddChangeDeviceViewController") as? AddChangeDeviceViewController {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate

    func initLocationManager(){
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkAuthorizationStatus(){
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdatingLocation(){
        locationManager.startUpdatingLocation()
        isLocating = true
    }
    
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
        isLocating = false
    }
    
    func centerMapOnLocation(_ location: CLLocationCoordinate2D, _ regionRadius: CLLocationDistance = 100.0){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0,regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func addAnnotation(title:String, lat:Double, long:Double){
        let a = MKPointAnnotation()
        a.coordinate = CLLocationCoordinate2DMake(lat, long)
        a.title = title
        mapView.setCenter(a.coordinate, animated: true)
        mapView.addAnnotation(a)
    }
    
    func add(annotation: MKPointAnnotation, title:String, lat:Double, long:Double){
        annotation.coordinate = CLLocationCoordinate2DMake(lat, long)
        annotation.title = title
        mapView.setCenter(annotation.coordinate, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func move(annotation: MKPointAnnotation, lat:Double, long:Double){
        annotation.coordinate = CLLocationCoordinate2DMake(lat, long)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
//        centerMapOnLocation(locations[0].coordinate)
//        addAnnotation("Current Location", locations[0])
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        isLocating = false
//        self.alert(title: "Location Error", msg: error.localizedDescription)
//    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PetProfileViewController") as? PetProfileViewController {
            return vc
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    // MARK: - View Helper
    
    enum blurViewAction {
        case open, close
    }
    func blurView(_ action:blurViewAction, speed:Double = 1, animated:Bool = true){
        
        if animated {
            UIView.animate(withDuration: speed, animations: {
                let dy = action == .open ? self.blurView.frame.minY - self.blurView.center.y : self.blurView.center.y - self.blurView.frame.minY
                self.blurView.transform = CGAffineTransform(translationX: 0, y: dy)
            }) { (done) in
                self.bottomConstraintBlurView.constant = action == .open ? self.opened : self.closed
                self.blurView.transform = CGAffineTransform.identity
            }
        }else{
            self.bottomConstraintBlurView.constant = action == .open ? self.opened : self.closed
        }
    }
    
}

class petCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}






















