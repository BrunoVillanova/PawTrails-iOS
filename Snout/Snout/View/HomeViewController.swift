//
//  HomeViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
//import CoreLocation

class _pet {
    var name:String
    var tracking:Bool
    init(_ _name:String) {
        name = _name
        tracking = false
    }
}

class HomeViewController: UIViewController, HomeView, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var bottomConstraintBlurView: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSurnameLabel: UILabel!
    @IBOutlet weak var actionBlurView: UIVisualEffectView!
    
    fileprivate let presenter = HomePresenter()
    fileprivate var notifier:Notifier!
    
    fileprivate let closed:CGFloat = -170.0, opened:CGFloat = -40.0
    
    fileprivate var annotations = [String:MKLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.actionBlurView.round()
        self.blurView.round(radius: 20)
        self.presenter.attachView(self)
        self.notifier = Notifier(with: self.view)
        mapView.showsScale = false
        mapView.showsUserLocation = false
        blurView(.close, animated: false)
    }
    
    deinit {
        self.presenter.deteachView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.presenter.checkSignInStatus()
//        blurView(.close)
        let w = UIWindow(frame: self.view.frame)
        w.backgroundColor = UIColor.clear
        w.windowLevel = UIWindowLevelStatusBar + 1
        w.isHidden = false
        w.rootViewController = self
        w.makeKeyAndVisible()
        self.notifier.notConnectedToNetwork()

    }
    
    @IBAction func handleLongPressure(_ sender: UILongPressGestureRecognizer) {
        
        guard let indexPath = collectionView.indexPathForItem(at: sender.location(in: collectionView)) else {return}
        if indexPath.section != 0 {return}
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "PetProfileViewController") as? PetProfileViewController else {return}
        
        vc.pet = self.presenter.pets[indexPath.row]
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        let y = sender.translation(in: self.view).y / 2.5
        if (y < 0 && bottomConstraintBlurView.constant > opened) || (y > 0 && bottomConstraintBlurView.constant < closed) { bottomConstraintBlurView.constant += y }
        
        if sender.state == .ended {
            blurView(y < 0 ? .open : .close, speed: 0.5)
        }
    }

    @IBAction func changeMapInfo(_ sender: UIButton) {
        mapView.mapType = mapView.mapType == MKMapType.standard ? MKMapType.satellite : MKMapType.standard
    }
    
//    @IBAction func locationAction(_ sender: UIButton) {
//        mapView.showsUserLocation = !mapView.showsUserLocation
//    }
    
    // MARK: - HomeView
    
    func errorMessage(_ error: errorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func userNotSignedIn() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func reload() {
        self.userNameLabel.text = self.presenter.user.name
        self.userSurnameLabel.text = self.presenter.user.surname        
        self.collectionView.reloadData()
    }
    
    func startTracking(_ name: String, lat:Double, long:Double) {
        self.annotations[name] = MKLocation(title: name, lat: lat, long: long)
        self.mapView.addAnnotation(self.annotations[name]!)
        self.mapView.setVisibleMapForAnnotations()
        self.collectionView.reloadData()
    }
    
    func updateTracking(_ name: String, lat:Double, long:Double) {
        self.annotations[name]?.move(lat: lat, long: long)
    }
    
    func stopTracking(_ name: String) {
        guard let a = self.annotations[name] else {
            self.errorMessage(errorMsg(title:"", msg:""))
            return
        }
        self.mapView.removeAnnotation(a)
        self.annotations.removeValue(forKey: name)
        self.collectionView.reloadData()
    }
    
    // MARK: - Connection Notifications
    
    func connectedToNetwork() {
        self.notifier.connectedToNetwork()
    }
    
    func notConnectedToNetwork() {
        self.notifier.notConnectedToNetwork()
    }

    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? self.presenter.pets.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! petCell
        cell.circle()
        if indexPath.section == 0 {
            let pet = self.presenter.pets[indexPath.row]
            cell.imageView.backgroundColor = blueSystem
            cell.imageView.image = UIImage()
            cell.imageView.alpha = pet.tracking ? 1.0 : 0.4
        }else{
            cell.imageView.backgroundColor = blueSystem
            cell.imageView.image = UIImage(named: "add")
            cell.imageView.alpha = 1.0
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {

            if self.presenter.pets[indexPath.row].tracking {
                
                self.presenter.stopTracking(indexPath.row)

            }else{
                
                self.presenter.startTracking(indexPath.row)
                
            }
        }else if indexPath.section == 1 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AddChangeDeviceViewController") as? AddChangeDeviceViewController {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - View Helper
    
    enum blurViewAction {
        case open, close
        
        init(direction:Int) {
            self = direction < 0 ? .open : .close
        }
    }
    func blurView(_ action:blurViewAction, speed:Double = 1, animated:Bool = true){
        
        if (self.bottomConstraintBlurView.constant == closed && action == .close) || (self.bottomConstraintBlurView.constant == opened && action == .open) { return }
        
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
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKLocation {
            // Better to make this class property
            let annotationIdentifier = "mkl"
            
            var annotationView: MKAnnotationView?
            if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
                annotationView = dequeuedAnnotationView
                annotationView?.annotation = annotation
            }
            else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            
            if let annotationView = annotationView {
//                let mkl = annotation as! MKLocation
                // Configure your annotation view here
                annotationView.canShowCallout = true
//                annotationView.backgroundColor = mkl.color
//                annotationView.frame.size = CGSize(width: 15, height: 15)
//                let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//                leftView.round()
//                leftView.backgroundColor = mkl.color
//                annotationView.leftCalloutAccessoryView = leftView
                annotationView.image = UIImage(named: "pet")
            }
            return annotationView
        }
        return nil
    }
    
}

class petCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

class MKLocation: MKPointAnnotation {
    var color:UIColor
    
    init(title:String, lat:Double, long:Double, color: UIColor = blueSystem) {
        self.color = color
        super.init()
        self.title = title
        self.coordinate = CLLocationCoordinate2DMake(lat, long)
    }
    
    func move(lat:Double, long:Double){
        self.coordinate = CLLocationCoordinate2DMake(lat, long)
    }
    
}




















