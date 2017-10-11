//
//  PetProfileCollectionViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 07/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit





class PetProfileCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PetView {
    
    let cellId = "cellId"
    let titles = ["Profile", "Activity", "SafeZone", "Share"]
    
    var pet:Pet!

    var fromMap: Bool = false
    
    
    fileprivate var currentUserId = -1
    fileprivate var petOwnerId = -2
    fileprivate var appUserId = -3
    
     let presenter = PetPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"switch-device-button-1x-png"), style: .plain, target: self, action: #selector(addTapped))

 
        presenter.attachView(self, pet:pet)
        
        if let pet = pet {
            load(pet)
            reloadPetInfo()
            reloadUsers()
            reloadSafeZones()

//            removeLeaveButton.setTitle(pet.isOwner ? "Remove Pet" : "Leave Pet", for: .normal)
        }
        
        if fromMap {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(dismissAction(sender: )))
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        collectionView?.collectionViewLayout.invalidateLayout()
        setUpMenuBar()
        setupCollectionView()
        addButton()
        if !pet.isOwner {
            button.isHidden = true
        } else {
            button.isHidden = false

        }
        
    }
    
    deinit {
        presenter.deteachView()
    }
    
    
 
    
    // Floating button.
    let button = UIButton()

    fileprivate func addButton(){
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "StopTripButton-1x-png"), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        button.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -5).isActive = true
        button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5).isActive = true
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    
    func buttonAction(sender: UIButton!) {
        if !pet.isOwner {
            self.alert(title: "", msg: "You cannot add user for this pet because you don't own it", type: .blue, disableTime: 5, handler: nil)
        } else {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AddPetUserViewController") as? AddPetUserViewController {
                vc.pet = pet
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    

    // To change Device
    func addTapped() {
        self.performSegue(withIdentifier: "ChangeDevice", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeDevice" {
            if let navigationController = segue.destination as? UINavigationController {
                if let childVC = navigationController.topViewController as? AddPetDeviceTableViewController {
                    childVC.petId = pet.id
                }
            }
        }
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.loadPet(with: pet.id)
        presenter.getPet(with: pet.id)
        presenter.startPetsGPSUpdates(for: pet.id) { (data) in

            print("I GOT THE DATA \(data)")
        }
        presenter.startPetsGeocodeUpdates(for: pet.id, { (type,name) in
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Released Geocode \(type) - \(name)")
            if type == .pet {
                self.load(locationAndTime: name)
            }else if type == .safezone {
                self.presenter.getPet(with: self.pet.id)
            }
        })
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.stopPetGPSUpdates(of: pet.id)
        presenter.stopPetsGeocodeUpdates()
    }
    
    
    
    func reloadPetInfo() {
        presenter.loadPet(with: pet.id)
    }
    
    
    func reloadSafeZones() {
        presenter.loadSafeZones(for: pet.id)
    }
    
    
    func reloadUsers(onlyDB: Bool = false) {
        if onlyDB {
            presenter.getPet(with: pet.id)
            //reload users?
        }else{
            presenter.loadPetUsers(for: pet.id)
        }
    }
    
    
    func load(locationAndTime: String){
        print("Here is the location ANd Time\(locationAndTime)")
    }
    


    // PetView
    
    func removed() {
}

    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }

    
    func load(_ pet: Pet) {
        self.pet = pet
        navigationItem.title = pet.name
        
        self.collectionView?.reloadData()
}
    
    func petNotFound() {
        alert(title: "", msg: "couldn't load pet")
    }
    
    func petRemoved() {
        if let petList = navigationController?.viewControllers.first(where: { $0 is PetsViewController}) as? PetsViewController {
            petList.reloadPets()
            navigationController?.popToViewController(petList, animated: true)
        }else{
            popAction(sender: nil)
        }
    }
    
    
    func loadUsers() {
        pet.users = presenter.users
}
    

    
    func loadSafeZones() {
        pet.safezones = presenter.safezones
        if self.presenter.safezones.count == 0 { return }
        let safezonesGroup = DispatchGroup()
        
        for safezone in self.presenter.safezones {
            // Address
            if safezone.address == nil {
                
                guard let center = safezone.point1 else {
                    Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "No center point found!")
                    break
                }
                GeocoderManager.Intance.reverse(type: .safezone, with: center, for: safezone.id)
            }
            // Map
            if safezone.preview == nil {
                guard let center = safezone.point1?.coordinates else {
                    Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "No center point found!")
                    continue
                }
                guard let topCenter = safezone.point2?.coordinates else {
                    Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "No topcenter point found!")
                    continue
                }
                
                safezonesGroup.enter()
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "map", safezone.id)
                self.buildMap(center: center, topCenter: topCenter, shape: safezone.shape, handler: { (image) in
                    if let image = image, let data = UIImagePNGRepresentation(image) {
                        Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "released", safezone.id)
                        self.presenter.set(imageData: data, for: safezone.id) { (errorMsg) in
                            if let errorMsg = errorMsg {
                                self.errorMessage(errorMsg)
                            }
                            safezonesGroup.leave()
                        }
                    }
                })
            }
        }
        
        safezonesGroup.notify(queue: .main, execute: {
            self.presenter.getPet(with: self.pet.id)
            
        })
    }

    func buildMap(center: CLLocationCoordinate2D, topCenter: CLLocationCoordinate2D, shape: Shape, handler: @escaping ((UIImage?)->())){
        if CLLocationCoordinate2DIsValid(center) && CLLocationCoordinate2DIsValid(topCenter) {
            SnapshotMapManager.Intance.performSnapShot(with: center, topCenter: topCenter, shape: shape, handler: { (image) in
                handler(image)
            })
        }else{
            self.errorMessage(ErrorMsg.init(title: "", msg: "wrong coordinates"))
            handler(nil)
        }
    }


    func setupCollectionView() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ProfileCell.self, forCellWithReuseIdentifier: "cell")
        
        
        
        collectionView?.register(SafezZoneParentCell.self, forCellWithReuseIdentifier: "cell3")
        
        
        
        
        
        let nib = UINib(nibName: "PetProfileCollectionViewCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: "myCell")
        collectionView?.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)
        collectionView?.isPagingEnabled = true
    }
    
    
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.petProfileCollectionView = self
        return mb
    }()
    
    
    private func setUpMenuBar() {
        view.addSubview(menuBar)
        view.addConstraintsWithFormat("H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat("V:[v0(50)]", views: menuBar)
        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 4
    }
    
    
    // Mark - to highligh menu bar when selected
    
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
    }

    
    func scrollToMenuIndex(_ menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
 
    }
    
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4

    }
    
 

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! PetProfileCollectionViewCell
            cell.petBirthdayLabel.text = pet.birthday?.toStringShow
            cell.typeLabel.text = self.pet.typeString
            cell.breedLabel.text = self.pet.breedsString
            cell.genderLabel.text = self.pet.gender?.name
            cell.weightLabel.text = self.pet.weightString
            cell.backgroundColor = UIColor.white
            cell.petName.text = self.pet.name

            if let imageData = self.pet.image {
                cell.petImage.image = UIImage(data: imageData as Data)
            }
            return cell
        } else if indexPath.item == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfileCell
            return cell
        }
        

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell3", for: indexPath) as! SafezZoneParentCell
        cell.backgroundColor = UIColor.blue
        return cell

        
        
   }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 120)
    }
    
    
    func presentEditSafezoneViewController(petId: Int, isOwner: Bool, safeZone: SafeZone) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddEditSafeZOneController") as! AddEditSafeZOneController
        viewController.petId = petId
        viewController.isOwner = isOwner
        viewController.safezone = safeZone
        navigationController?.pushViewController(viewController, animated: true)
    }


}



class ActivityCell: BaseCell {
    override func setupViews() {
        self.backgroundColor = UIColor.green

    }
}


//class SafeZoneCell: BaseCell {
//    override func setupViews() {
//        self.backgroundColor = UIColor.blue
//    }
//}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

