//
//  TripScreenViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 06/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import SCLAlertView
import Convert

class TripScreenViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: PTMapView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    let locationManager = CLLocationManager()
    var petArray = [Dictionary<String,String>]()
    
    var runningTripArray = [Trip]()
    var tripIds = [Int]()
    var adventurePaused: Bool?
    
    var scrollViewPageIndex :Int {
        set {
            let contentX = collectionView.frame.size.width * CGFloat(newValue)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: { [weak self] _ in
                    self?.collectionView.contentOffset = CGPoint.init(x: contentX, y: 0)
                })
            }
        }
        get {
            return Int(collectionView.contentOffset.x / collectionView.frame.size.width)
        }
    }
    var selectedPageIndex = Variable(Int())
    
    final let bag = DisposeBag()
    
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
    
    let disposeBag = DisposeBag()
    
    //MARK: -
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        mapView.tripMode = true
        
        let activeTripsObservable = DataManager.instance.getActivePetTrips()
        
        activeTripsObservable.map{$0.count}.bind(to: pageControl.rx.numberOfPages).disposed(by: disposeBag)
        
        activeTripsObservable
            .bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: TripDetailsCell.self)) { (row, element, cell) in
                cell.configureWithTrip(element)
            }
            .disposed(by: disposeBag)
        
        activeTripsObservable
            .subscribe(onNext: { (activeTrips) in
                let pausedTrips = activeTrips.filter { $0.status == 1 }
                self.adventurePaused = (pausedTrips.count > 0)
                self.pauseButton.isEnabled = true
                
                if self.adventurePaused! {
                    self.pauseButton.changeImageAnimated(image: #imageLiteral(resourceName: "StartTrip-1x-png"))
                } else {
                    self.pauseButton.changeImageAnimated(image: #imageLiteral(resourceName: "PauseTripButton-1x-png"))
                }
                
                if self.pauseButton.isHidden {
                    self.pauseButton.alpha = 0
                    self.pauseButton.isHidden = false
                    UIView.animate(withDuration: 0.3, animations: {
                        self.pauseButton.alpha = 1;
                    })
                }
                
                if self.joinButton.isHidden {
                    self.joinButton.alpha = 0
                    self.joinButton.isHidden = false
                    UIView.animate(withDuration: 0.3, animations: {
                        self.joinButton.alpha = 1;
                    })
                }
                
            }).addDisposableTo(disposeBag)
        
        self.setupSubViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func setupSubViews() {
        selectedPageIndex.asObservable().bind(to: pageControl.rx.currentPage).addDisposableTo(bag)
        
        collectionView.rx.contentOffset.bind { [weak self] (point) in
            guard let _ = self?.collectionView.frame.size.width else {
                return
            }
            
            if Int(point.x.truncatingRemainder(dividingBy: (self?.collectionView.frame.width)!)) != 0 {
                return
            }
            
            self?.selectedPageIndex.value = (self?.scrollViewPageIndex)!
            
            }.addDisposableTo(bag)
    }
    
    override func viewDidLayoutSubviews() {
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
    
    //MARK: -
    //MARK: IBActions
    @IBAction func focousOnUserBtnPressed(_ sender: Any) {
        self.mapView.setVisibleMapFor([self.mapView.userLocation.coordinate])
    }
    
    
    @IBAction func AddPetsToTripBtnPressed(_ sender: Any) {
        if let nc = self.storyboard?.instantiateViewController(withIdentifier: "selectPetsNavigation") as? UINavigationController,
            let selectPetsViewController = nc.topViewController as? SelectPetsVC {
            selectPetsViewController.action = selectPetsAction.joinAdventure
            self.navigationController?.present(nc, animated: true, completion: nil)
        }
    }
    
    @IBAction func pauseTripBtnPressed(_ sender: Any) {
        
        let theButton = sender as! UIButton
        theButton.isEnabled = false
        
        let isPaused = self.adventurePaused!
        var title: String
        var subTitle: String
        var buttonOkTitle: String
        var buttonCancelTitle: String
        
        if !isPaused {
            title = "Pause Adventure?"
            subTitle = "You can resume it later."
            buttonOkTitle = "Pause it now!"
            buttonCancelTitle = "Let's continue!"
        } else {
            title = "Resume Adventure?"
            subTitle = "Let's continue our adventure."
            buttonOkTitle = "Resume the adventure!"
            buttonCancelTitle = "Keep it paused!"
        }
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: true
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton(buttonOkTitle) {
            
            if (!isPaused) {
                DataManager.instance.pauseAdventure().subscribe(onNext: { (stoppedTrips) in
//                    self.navigationController?.dismiss(animated: true, completion: nil)
                }).addDisposableTo(self.disposeBag)
            } else {
                DataManager.instance.resumeAdventure().subscribe(onNext: { (stoppedTrips) in
//                    self.navigationController?.dismiss(animated: true, completion: nil)
                }).addDisposableTo(self.disposeBag)
            }
        }
        
        alertView.addButton(buttonCancelTitle) {
            print("User canceled action!")
        }

        alertView.showTitle(
            title, // Title of view
            subTitle: subTitle, // String of view
            duration: 0.0, // Duration to show before closing automatically, default: 0.0
            completeText: "Done", // Optional button value, default: ""
            style: .notice, // Styles - see below.
            colorStyle: 0xD4143D,
            colorTextButton: 0xFFFFFF
            //            circleIconImage: alertViewIcon
        )


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
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        scrollViewPageIndex = sender.currentPage
    }
}

extension TripScreenViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.runningTripArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let trip = self.runningTripArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TripDetailsCell
        cell.configureWithTrip(trip)
        
        return cell
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

class TripDetailsCell: UICollectionViewCell {
    
    
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
    
    override func awakeFromNib() {
        self.maskImage.maskImage = UIImage(named: "userprofilemask-1x-png_360")
        self.totalDistanceImageVIew.image = UIImage(named: "TotalDistanceLabel-1x-png")
        self.totalDistancesubLabel.text = "total distance"
        self.totalTimeImageVIew.image = UIImage(named: "TotalTimeLabel-1x-png")
        self.totalTimeSubLabel.text = "total time"
        self.currentSpeedImageView.image = UIImage(named: "CurrentSpeedLabel-1x-png")
        self.currentSpeedsubLabel.text = "current speed"
        self.avarageSpeedImageView.image = UIImage(named: "AvgSpeedLabel-1x-png")
        self.avarageSpeedSubLabel.text = "avarge speed"
    }
    
    func configureWithTrip(_ trip: Trip) {
        if let petName = trip.pet.name {
            self.petName.text = petName
        }
        
        
        self.totalDistance.text = "120.0 km"
        
        if let imageData = trip.pet.image {
            self.userProfileImg.image = UIImage(data: imageData)
        }
        
        self.avargeSpeed.text = "142 bpm"
        self.currentSpeed.text = "6.2 km/h"
        self.totalTime.text = "00:43:27"
    }
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

