//
//  TripScreenViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 06/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit


class TripScreenViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pageControl: UIPageControl!

    let locationManager = CLLocationManager()
    var petArray = [Dictionary<String,String>]()
    
    var runningTripArray = [TripList]()
    var tripIds = [Int]()
    
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
    
    //MARK: -
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        pageControl.hidesForSinglePage = true
        
        // Access user location
        if CLLocationManager.locationServicesEnabled() {
//            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if tripIds.count == 1 {
            self.pageControl.isHidden = true
        } else {
            self.pageControl.isHidden = false
        }
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
    
    //MARK: -
    //MARK: Private Methods
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

    func getRunningandPausedTrips() {
        APIRepository.instance.getTripList([0]) { (error, trips) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let trips = trips {
                    for trip in trips {
                        self.runningTripArray.append(trip)
                        print("Here is your truos \(self.runningTripArray)")
                        for tripp in self.runningTripArray {
                            self.tripIds.append(tripp.id)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: -
    //MARK: IBActions
    @IBAction func focousOnUserBtnPressed(_ sender: Any) {
        self.mapView.setVisibleMapFor([self.mapView.userLocation.coordinate])
        
    }
    
    
    @IBAction func AddPetsToTripBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "join", sender: self)
        
        
    }
    
    @IBAction func pauseTripBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func StopTripBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "finish", sender: self)
        
    }
    
    @IBAction func BackBtnPressed(_ sender: Any) {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            let testController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
            testController.selectedIndex = 0
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = testController
        }
    }
}

extension TripScreenViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tripIds.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CsustomCell

        cell.maskImage.maskImage = UIImage(named: "userprofilemask-1x-png_360")
        cell.totalDistanceImageVIew.image = UIImage(named: "TotalDistanceLabel-1x-png")
        cell.totalDistancesubLabel.text = "total distance"
        cell.totalTimeImageVIew.image = UIImage(named: "TotalTimeLabel-1x-png")
        cell.totalTimeSubLabel.text = "total time"
        cell.currentSpeedImageView.image = UIImage(named: "CurrentSpeedLabel-1x-png")
        cell.currentSpeedsubLabel.text = "current speed"
        cell.avarageSpeedImageView.image = UIImage(named: "AvgSpeedLabel-1x-png")
        cell.avarageSpeedSubLabel.text = "avarge speed"
        
        cell.petName.text = "My Pet"
        cell.totalDistance.text = "8.32 KM"
        cell.userProfileImg.image = UIImage(named: "")
        cell.avargeSpeed.text = "142 bpm"
        cell.currentSpeed.text = "6.2 km/h"
        cell.totalTime.text = "00:43:27"
        
        return cell
    }
}

extension TripScreenViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.item
    }
}

extension TripScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: myCollectionViewWidith, height: myCollectionViewHeight)
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
}

class CsustomCell: UICollectionViewCell {
    
    @IBOutlet weak var maskImage: UiimageViewWithMask!
    @IBOutlet weak var totalDistanceImageVIew: UIImageView!
    @IBOutlet weak var totalDistancesubLabel: UILabel!
    
    @IBOutlet weak var totalTimeImageVIew: UIImageView!
    @IBOutlet weak var totalTimeSubLabel: UILabel!
    
    @IBOutlet weak var currentSpeedImageView: UIImageView!
    @IBOutlet weak var currentSpeedsubLabel: UILabel!
    
    @IBOutlet weak var avarageSpeedImageView: UIImageView!
    @IBOutlet weak var avarageSpeedSubLabel: UILabel!
    
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var avargeSpeed: UILabel!
    @IBOutlet weak var currentSpeed: UILabel!
    @IBOutlet weak var totalTime: UILabel!
}

extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}

