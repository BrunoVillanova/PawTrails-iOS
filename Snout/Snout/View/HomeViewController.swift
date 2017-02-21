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

class HomeViewController: UIViewController, HomeView, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate let petAnnotation = MKPointAnnotation()
    
    fileprivate let presenter = HomePresenter()
    
    fileprivate var first = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
        addAnnotation()
        centerMapOnLocation(petAnnotation.coordinate)
    }
    
    deinit {
        self.presenter.deteachView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.presenter.checkSignInStatus()
//        self.initLocationManager()
        self.checkAuthorizationStatus()
//        self.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //
        print("enjoy")
    }
    
    @IBAction func refreshAction(_ sender: UIBarButtonItem) {
        SocketIOManager.Instance.sendTry()
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
    
    
//    func addAnnotation(_ title: String, _ location:CLLocationCoordinate2D){
    func addAnnotation(){
        petAnnotation.coordinate = CLLocationCoordinate2DMake(39.6131615,2.6314731)
        petAnnotation.title = title
        mapView.addAnnotation(petAnnotation)
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






















