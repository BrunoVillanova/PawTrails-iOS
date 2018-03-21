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
    var activeTrips = [Trip]()
    
    //MARK: -
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        self.pageControl.isHidden = true
        
        let activeTripsObservable: Observable<[Trip]> = DataManager.instance.getActivePetTrips()
        let allPetDeviceData = DataManager.instance.allPetDeviceData(.live)
    
        activeTripsObservable
            .flatMap { (trips) -> Observable<[Trip]> in
                Reporter.debugPrint("TripScreen -> activeTripsObservable -> flatMap -> \(trips.count)")
                let petIDsOnTrip = trips.map { $0.pet.id }
                self.activeTrips = trips
                return allPetDeviceData
                    .map({ (petDeviceDataList) -> [PetDeviceData] in
                        Reporter.debugPrint("TripScreen -> allPetDeviceData -> map")
                        return petDeviceDataList.filter({ (petDeviceData) -> Bool in
                            return petIDsOnTrip.contains(Int(petDeviceData.pet.id))
                        })
                    })
                    .flatMap({ (result) -> Observable<[Trip]> in
                        Reporter.debugPrint("TripScreen -> allPetDeviceData -> flatMap \(result.count)")
                        return DataManager.instance.getApiTrips([0,1])
                    }).ifEmpty(default: trips)
            }
            .bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: TripDetailsCell.self)) { (row, element, cell) in
                Reporter.debugPrint("TripScreen -> Configure cell")
                self.pageControl.isHidden = false
                cell.configureWithTrip(element)
            }
            .disposed(by: disposeBag)

        
        activeTripsObservable.map{$0.count}.bind(to: pageControl.rx.numberOfPages).disposed(by: disposeBag)
        

        activeTripsObservable
            .subscribe(onNext: { (activeTrips) in
                let pausedTrips = activeTrips.filter { $0.status == 1 }
                self.adventurePaused = (pausedTrips.count > 0)
                self.pauseButton.isEnabled = true
                
                if self.adventurePaused! {
                    self.pauseButton.changeImageAnimated(image: #imageLiteral(resourceName: "ResumeTripIcon"))
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
                
            }).disposed(by: disposeBag)
        
        self.setupSubViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated: true)
        mapView.startTripMode()
    }
    
    private func setupSubViews() {
        selectedPageIndex.asObservable().bind(to: pageControl.rx.currentPage).disposed(by: disposeBag)
        
        selectedPageIndex.asObservable().subscribe(onNext: { (pageIndex) in
            if self.activeTrips.count > pageIndex {
                let trip = self.activeTrips[pageIndex]
                self.mapView.focusOnPet(trip.pet.id)
            }
            
        }).disposed(by: disposeBag)
        
        collectionView.rx.contentOffset.bind { [weak self] (point) in
            guard let _ = self?.collectionView.frame.size.width else {
                return
            }
            
            if Int(point.x.truncatingRemainder(dividingBy: (self?.collectionView.frame.width)!)) != 0 {
                return
            }
            
            self?.selectedPageIndex.value = (self?.scrollViewPageIndex)!
            
            }.disposed(by: disposeBag)
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
        mapView.showAnnotations([self.mapView.userLocation], animated: true)
    }
    
    
    @IBAction func AddPetsToTripBtnPressed(_ sender: Any) {
        if let nc = self.storyboard?.instantiateViewController(withIdentifier: "selectPetsNavigation") as? UINavigationController,
            let selectPetsViewController = nc.topViewController as? SelectPetsVC {
            selectPetsViewController.action = selectPetsAction.joinAdventure
            self.navigationController?.present(nc, animated: true, completion: nil)
        }
    }
    
    @IBAction func pauseTripBtnPressed(_ sender: Any) {
        
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
                self.showLoadingView()
                DataManager.instance.pauseAdventure().subscribe(onNext: { (trips) in
                    Reporter.debugPrint("onNext")
                    self.hideLoadingView()
                }, onError: { (error) in
                    Reporter.debugPrint("onError")
                    self.hideLoadingView()
                }, onCompleted: {
                    Reporter.debugPrint("onCompleted")
                    self.hideLoadingView()
                }, onDisposed: {
                    Reporter.debugPrint("onDisposed")
                    self.hideLoadingView()
                }).disposed(by: self.disposeBag)
            } else {
                self.showLoadingView()
                DataManager.instance.resumeAdventure().subscribe(onNext: { (stoppedTrips) in
                    self.hideLoadingView()
                }).disposed(by: self.disposeBag)
            }
        }
        
        alertView.addButton(buttonCancelTitle) {
            Reporter.debugPrint("User canceled action!")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is FinishAdventureVC {
            let vc = (segue.destination as! FinishAdventureVC)
            vc.delegate = self
        }
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


extension TripScreenViewController: FinishAdventureVCDelegate {
    
    func adventureFinished(viewController: FinishAdventureVC, trips: [Trip]?) {
        
        viewController.dismiss(animated: true, completion: {
            if let trips = trips {
                let tripDetailViewController = TripDetailViewController()
                tripDetailViewController.trips = trips
                tripDetailViewController.delegate = self
                let navigatiorController = UINavigationController(rootViewController: tripDetailViewController)
                
                self.present(navigatiorController, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func adventureResumed(viewController: FinishAdventureVC, trips: [Trip]?) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension TripScreenViewController: TripDetailViewControllerDelegate {
    
    func closed(viewController: TripDetailViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}

class TripDetailsCell: UICollectionViewCell {
    
    
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
    @IBOutlet weak var balloonImageView: PTBalloonImageView!
    @IBOutlet weak var avargeSpeed: UILabel!
    @IBOutlet weak var currentSpeed: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    var trip: Trip? {
        didSet {
            self.finalTotalTime = trip!.totalTime!
            startTimerIfNeeded()
            stopTimerIfNeeded()
        }
    }
    var totalTimeTimer : Timer?
    var finalTotalTime: Int64 = 0
    
    override func awakeFromNib() {
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
        
        self.trip = trip
        
        if let petName = trip.pet.name {
            self.petName.text = petName
        }
        
        self.balloonImageView.imageUrl = trip.pet.imageURL
        
        // Set defaults
        var tripTotalDistanceText = "0 km"
        var tripAverageSpeedText = "0 bpm"
        var tripCurrentSpeed = "0 km/h"


        if let totalDistanceInMeters = trip.totalDistance {
            let totalDistanceInKm = Double(totalDistanceInMeters)/1000.0
            tripTotalDistanceText = String(format:"%0.2f km", totalDistanceInKm)
        }
        
        if let averageSpeed = trip.steps {
            tripAverageSpeedText = String(format:"%2i bpm", averageSpeed)
        }
        
        if let currentSpeed = trip.averageSpeed {
            tripCurrentSpeed = String(format:"%.2f km/h", currentSpeed)
        }
        
        self.totalDistance.text = tripTotalDistanceText
        self.avargeSpeed.text = tripAverageSpeedText
        self.currentSpeed.text = tripCurrentSpeed
        self.totalTime.text = timeStampToTimeString(trip.totalTime)
    }
    
    func startTimerIfNeeded() {
        if (self.totalTimeTimer == nil && trip?.status == 0) {
            self.totalTimeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TripDetailsCell.tick), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimerIfNeeded() {
        if let totalTimeTimer = self.totalTimeTimer, let trip = trip, trip.status > 0 {
            totalTimeTimer.invalidate()
            self.totalTimeTimer = nil
        }
    }
    
    func timeStampToTimeString(_ timeStamp: Int64?) -> String {
        
        var hours = 0
        var minutes = 0
        var seconds = 0
        
        if let totalTime = timeStamp as Int64! {
            hours = Int(totalTime) / 3600
            minutes = Int(totalTime) / 60 % 60
            seconds = Int(totalTime) % 60
        }
        
       return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func tick() {
        DispatchQueue.global().async {
            if let totalTime = self.finalTotalTime as Int64! {
                self.finalTotalTime = totalTime+1
                
                DispatchQueue.main.async(execute: {
                    self.totalTime.text = self.timeStampToTimeString(self.finalTotalTime )
                })
            }
        }
        
    }
    
    
}

