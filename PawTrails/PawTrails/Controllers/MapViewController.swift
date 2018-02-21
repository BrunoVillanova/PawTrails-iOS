//
//  MapViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 04/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import GSMessages

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: PTMapView!
    @IBOutlet weak var petsCollectionView: UICollectionView!
    @IBOutlet weak var firstButtonfromthebottom: UIButton!
    @IBOutlet weak var secButtonFromTheBottom: UIButton!
    @IBOutlet weak var thirdButtonFromTheBottom: UIButton!
    @IBOutlet weak var refreshBarBtn: UIBarButtonItem!
    
    fileprivate let presenter = HomePresenter()
    var selectedPet: Pet?
    var data = [searchElement]()
    var activeTrips = [Trip]()
    var isDisplayedPetScreen = false

    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let disposeBag = DisposeBag()
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        UIApplication.shared.statusBarStyle = .default
        self.button.addTarget(self, action:  #selector(self.refreshBtnPressed(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "refresh-button"), for: .normal)
        self.navigationItem.rightBarButtonItem?.customView = button
//        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.showGpsUpdates()
        self.tabBarController?.tabBar.isHidden = false
        
        if isDisplayedPetScreen {
            reloadPets()
            isDisplayedPetScreen = false;
        }
    }
    
    
    func initialize() {
        
        mapView.calloutDelegate = self
        DataManager.instance.getActivePetTrips()
            .subscribe(onNext: { (tripList) in
                self.activeTrips = tripList
                Reporter.debugPrint("MapViewController -> getActivePetTrips \(tripList.count)")
                if (tripList.count > 0){
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
                    gestureRecognizer.delegate = self
                    self.alertwithGeature(title: "", msg: "ADVENTURE IN PROGRESS, CLICK TO RESUME", type: .red, disableTime: 150, geatureReconginzer: gestureRecognizer, handler: nil)
                } else {
                    Reporter.debugPrint("No running trips")
                    self.hideNotification()
                }

            }).disposed(by: disposeBag)
        
        
        DataManager.instance.allPetDeviceData(.live).subscribe(onNext: { (petDeviceDataList) in
            Reporter.debugPrint("MapViewController -> allPetDeviceData \(petDeviceDataList.count)")
            
            if (petDeviceDataList.count > 0) {
               self.hideMessage()
            } else {
                self.showMessage("Searching for new location...", type: GSMessageType.info,  options: [
                    .animation(.slide),
                    .animationDuration(0.3),
                    .autoHide(false),
                    .cornerRadius(0.0),
                    .height(44.0),
                    .hideOnTap(false),
                    //                .margin(.init(top: 64, left: 0, bottom: 0, right: 0)),
                    //                .padding(.zero),
                    .position(.top),
                    .textAlignment(.center),
                    .textNumberOfLines(0),
                    ])
            }
        }).disposed(by: disposeBag)
        
        firstButtonfromthebottom.contentHorizontalAlignment = .fill
        firstButtonfromthebottom.contentMode = .scaleToFill
        firstButtonfromthebottom.imageView?.contentMode = .scaleToFill
        
        petsCollectionView.delegate = self
        petsCollectionView.dataSource = self
        petsCollectionView.reloadData()
        petsCollectionView.isHidden = true
        
        presenter.attachView(self)
        reloadPets()
    }

    
    func reloadPets(){
        presenter.getPets()
    }
    
    deinit {
        self.presenter.deteachView()
    }
    
    
    // HomeView --
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectPetsViewController = segue.destination as? SelectPetsVC {
            selectPetsViewController.action = selectPetsAction.startAdventure
        }
    }
    @IBAction func refreshBtnPressed(_ sender: Any) {
        if  presenter.pets.count != 0 {
            var petIds = [Int]()
            for pet in presenter.pets {
                petIds.append(pet.id)
            }
            showIndicator()
            APIRepository.instance.getImmediateLocation(petIds) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.hideIndicator()
                } else {
                    self.hideIndicator()
                }
            }
        } else {
            self.showMessage("Please add a pet first", type: GSMessageType.info,  options: [
                .animation(.slide),
                .animationDuration(0.3),
                .autoHide(false),
                .cornerRadius(0.0),
                .height(44.0),
                .hideOnTap(false),
                .position(.top),
                .textAlignment(.center),
                .textNumberOfLines(0),
                ])
        }
    }
    
    
    func showIndicator() {
        self.refreshBarBtn.customView = self.activityIndicator
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.refreshBarBtn.isEnabled = false
    }
    
    func hideIndicator() {
        self.refreshBarBtn.isEnabled = true
        self.activityIndicator.stopAnimating()
        button.setImage(UIImage(named: "refresh-button"), for: .normal)
        self.navigationItem.rightBarButtonItem?.customView = button
    }
    
    @IBAction func firstButtonPressed(_ sender: Any) {
        if self.activeTrips.isEmpty {
            if let nc = self.storyboard?.instantiateViewController(withIdentifier: "selectPetsNavigation") as? UINavigationController,
                let selectPetsViewController = nc.topViewController as? SelectPetsVC {
                selectPetsViewController.action = selectPetsAction.startAdventure
                self.navigationController?.present(nc, animated: true, completion: nil)
            }
        } else {
            performSegue(withIdentifier: "adventrueInProgress", sender: nil)
        }
    }
    
    @IBAction func secButtonPressed(_ sender: Any) {
        if (!self.petsCollectionView.isHidden) {
            self.petsCollectionView.slideInAffect(direction: kCATransitionFromLeft)
            self.petsCollectionView.isHidden = true
        } else {
            self.petsCollectionView.slideInAffect(direction: kCATransitionFromRight)
            self.petsCollectionView.isHidden = false
        }
    }
    
    @IBAction func thirdButtonPressed(_ sender: Any) {
        mapView.showAnnotations([self.mapView.userLocation], animated: true)
    }
    
    
    func presentPet(_ pet: Pet, activityEnabled:Bool = false) {
        
        let nc = UINavigationController()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PetProfileCollectionViewController") as? PetInfromationViewController {
            vc.pet = pet
            nc.pushViewController(vc, animated: true)
            present(nc, animated: true, completion: nil)
        }
    }
    
    fileprivate func goToPetDetails(_ pet: Pet) {
        if let petDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetDetails") as? TabPageViewController {
            petDetailsViewController.pet = pet
            self.navigationController?.pushViewController(petDetailsViewController, animated: true)
        }
    }
}

//MARK: HomeView
extension MapViewController: HomeView {
    func success() {
    
    }
    
    func loadPets(){
        petsCollectionView.reloadData()
    }
    
    func reload() {
        
    }
    
    func userNotSigned() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func noPetsFound() {
        alert(title: "", msg: "No pets found", type: .blue)
    }
}

//MARK: GestureRecognizer Delegate
extension MapViewController: UIGestureRecognizerDelegate {
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        self.performSegue(withIdentifier: "adventrueInProgress", sender: nil)
//        self.hideNotification()
    }
}

//MARK: CollectionView DataSource
extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pet = presenter.pets[indexPath.item]
        let cell = petsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PetsCollectionViewCell
        cell.petImageCell?.imageUrl = pet.imageURL
        return cell
    }
}

//MARK: CollectionView Delegate
extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pet = presenter.pets[indexPath.item]
        self.mapView.focusOnPet(pet)
    }
}


//MARK: -
//MARK: MapView Delegate
extension MapViewController: PTPetCalloutViewDelegate {
    
    func didTapOnCallout(annotation: PTAnnotation) {
        
        if let petDeviceData = annotation.petDeviceData {
             isDisplayedPetScreen = true
             self.goToPetDetails(petDeviceData.pet)
        }
    }
}


//MARK: View Animations
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
