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

class HomeViewController: UIViewController, HomeView, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var topConstraintBlurView: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSurnameLabel: UILabel!

    fileprivate let locationManager = CLLocationManager()
    fileprivate let petAnnotation = MKPointAnnotation()
    
    fileprivate let presenter = HomePresenter()
    
    fileprivate let closed:CGFloat = 520.0
    fileprivate let opened:CGFloat = 345.0
    
    fileprivate var pets = [String]()
    fileprivate var user:User!

    fileprivate var first = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
//        self.topConstraintBlurView.constant = self.closed
//        addAnnotation()
//        centerMapOnLocation(petAnnotation.coordinate)
    }
    
    deinit {
        self.presenter.deteachView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.presenter.checkSignInStatus()
        if self.topConstraintBlurView.constant == opened {
            UIView.animate(withDuration: 1, animations: {
                self.blurView.transform = CGAffineTransform(translationX: 0, y: 175)
            }) { (done) in
                self.topConstraintBlurView.constant = self.closed
                self.blurView.transform = CGAffineTransform.identity
            }
        }
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        let y = sender.translation(in: self.view).y / 2.5
        if (y < 0 && topConstraintBlurView.constant > opened) || y > 0 && topConstraintBlurView.constant < closed {
            topConstraintBlurView.constant += y
            if topConstraintBlurView.constant < opened {
                topConstraintBlurView.constant = opened
            }else if topConstraintBlurView.constant > closed {
                topConstraintBlurView.constant = closed
            }
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
        let div = 100000.0
        let latd = (latitude/div)
        let longd = (longitude/div)
        print(latd, longd)
        let lat = petAnnotation.coordinate.latitude + latd
        let long = petAnnotation.coordinate.longitude + longd
        petAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat,longitude: long)
        centerMapOnLocation(petAnnotation.coordinate)
    }
    
    func checkLocationAuthorization() {
        checkAuthorizationStatus()
    }
    
    func reload(_ user: User, _ pets: [Pet]) {
        self.user = user
        //        self.pets = pets
        self.userNameLabel.text = user.name
        self.userSurnameLabel.text = user.surname
        self.pets.append("Hi")
        self.pets.append("Hi")
        self.pets.append("Hi")
        self.pets.append("Hi")
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
            cell.track.circle()
            cell.track.addTarget(self, action: #selector(trackPet(_:)), for: .touchUpInside)
        //        cell.track.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI*(7.0/4.0)))
            cell.track.isEnabled = true
            cell.track.isHidden = false
            cell.imageView.backgroundColor = UIColor.lightGray
            if cell.isSelected {
                cell.imageView.border()
            }else{
                cell.imageView.border(color: .clear, width: 0.0)
            }
        }else{
            cell.track.isEnabled = false
            cell.track.isHidden = true
            cell.imageView.backgroundColor = UIColor.white
        }
        return cell
    }
    
    func trackPet(_ sender: UIButton)
    {
        addAnnotation()
        centerMapOnLocation(self.petAnnotation.coordinate)
    }
    
    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
//            self.alert(title: "Pet Profile", msg: "UnderConstruction")
            
        }else if indexPath.section == 1 {
//            self.alert(title: "Add New Pet", msg: "UnderConstruction")
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
    }
    
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
    }
    
    func centerMapOnLocation(_ location: CLLocationCoordinate2D, _ regionRadius: CLLocationDistance = 100.0){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0,regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func addAnnotation(){
        petAnnotation.coordinate = CLLocationCoordinate2DMake(39.6131615,2.6314731)
        petAnnotation.title = title
        mapView.addAnnotation(petAnnotation)
        mapView.setCenter(petAnnotation.coordinate, animated: true)
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
//        if first {
//            centerMapOnLocation(locations[0])
//            addAnnotation("Current Location", locations[0].coordinate)
//            first = false
//        }
//    }
    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        self.alert(title: "Location Error", msg: error.localizedDescription)
//    }
}

class petCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var track: UIButton!
}






















