//
//  TripScreenViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 06/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit

class TripScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var pageControl: UIPageControl!
    
    let locationManager = CLLocationManager()

    
    

    
    
    
    
    let peetArray = ["Mohamed", "Mjkkkf", "kjfdkjdf"]
    
    var petArray = [Dictionary<String,String>]()

    // Variables to hold the width and hights of the collectionview.
    
    var myCollectionViewHeight: CGFloat = 0.0 {
        didSet {
            if myCollectionViewHeight != oldValue {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    var myCollectionViewWidith: CGFloat = 0.0 {
        didSet {
            if myCollectionViewHeight != oldValue {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        pageControl.hidesForSinglePage = true
        
        // Access user location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.showsUserLocation = true
        
          requestLocationAccess()


    }
    
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
            
        case .denied, .restricted:
            alert(title: "", msg: "Location Access denied")
            
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated: true)
    }


    override func viewDidLayoutSubviews() {
        
        pageControl.hidesForSinglePage = true

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        
            collectionView.isPagingEnabled = true
            collectionView.showsHorizontalScrollIndicator = false
        }

        myCollectionViewHeight = collectionView.frame.size.height
        myCollectionViewWidith = collectionView.frame.size.width
    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peetArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CsustomCell
        cell.petNameLabel.text = peetArray[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
 
        return CGSize(width: myCollectionViewWidith, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.item
    }
    
    
    @IBAction func focousOnUserBtnPressed(_ sender: Any) {
        
        self.mapView.setVisibleMapFor([self.mapView.userLocation.coordinate])

        
}
    

    
    
    @IBAction func AddPetsToTripBtnPressed(_ sender: Any) {
    }
    
    @IBAction func pauseTripBtnPressed(_ sender: Any) {
    }
    
    
    @IBAction func StopTripBtnPressed(_ sender: Any) {
    }
    
    
    @IBAction func BackBtnPressed(_ sender: Any) {
    }

    
}



class CsustomCell: UICollectionViewCell {
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var avarageSpeedLabel: UILabel!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
}

