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

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: PTMapView!
    @IBOutlet weak var petsCollectionView: UICollectionView!
    @IBOutlet weak var firstButtonfromthebottom: UIButton!
    @IBOutlet weak var secButtonFromTheBottom: UIButton!
    @IBOutlet weak var thirdButtonFromTheBottom: UIButton!
    
    var locationManager : CLLocationManager?
    fileprivate let presenter = HomePresenter()
    var selectedPet: Pet?
    var data = [searchElement]()
    var activeTrips = [Trip]()

    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let disposeBag = DisposeBag()
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.instance.getActivePetTrips()
            .subscribe(onNext: { (tripList) in
                self.activeTrips = tripList
                print("MapViewController -> getActivePetTrips \(tripList.count)")
                if (tripList.count > 0){
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
                    gestureRecognizer.delegate = self
                    self.alertwithGeature(title: "", msg: "ADVENTURE IN PROGRESS, CLICK TO RESUME", type: .red, disableTime: 150, geatureReconginzer: gestureRecognizer, handler: {
                    })
                } else {
                    print("No running trips")
                    self.hideNotification()
                }
                
            }).addDisposableTo(disposeBag)
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
    
    
    @IBAction func firstButtonPressed(_ sender: Any) {
        if self.activeTrips.isEmpty {
            performSegue(withIdentifier: "startAdventue", sender: sender)
        } else {
            performSegue(withIdentifier: "adventrueInProgress", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectPetsViewController = segue.destination as? SelectPetsVC {
            selectPetsViewController.action = selectPetsAction.startAdventure
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
        self.mapView.setVisibleMapFor([self.mapView.userLocation.coordinate])
    }
    
    
    func presentPet(_ pet: Pet, activityEnabled:Bool = false) {
        
        let nc = UINavigationController()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PetProfileCollectionViewController") as? PetInfromationViewController {
            vc.pet = pet
//            vc.fromMap = true
            nc.pushViewController(vc, animated: true)
            present(nc, animated: true, completion: nil)
        }
    }
    
    
}

//MARK: HomeView
extension MapViewController: HomeView {
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
        let cell = petsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PetsCollectionViewCell
        let pet = presenter.pets[indexPath.item]
        if let image = pet.image {
            cell.petImageCell?.image = UIImage(data: image)
        }
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
