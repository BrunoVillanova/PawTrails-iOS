//
//  PetProfileCollectionViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 07/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit


struct PetId {
    static var petId = Pet()
}


class PetProfileCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ProfilePetView {
    
    let cellId = "cellId"
    let titles = ["Profile", "Activity", "SafeZone", "Share"]
    
    var pet:Pet!
    
    var fromMap: Bool = false
    
    fileprivate let presenter = PetProfilePressenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"switch-device-button-1x-png"), style: .plain, target: self, action: #selector(addTapped))

        presenter.attachView(self, pet:pet)
 
        if let pet = pet {
            load(pet)
            presenter.getPet(with: pet.id)
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
        PetId.petId = pet
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        print("View Disappeared")
}

    // PetView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }

    
    func load(_ pet: Pet) {
        self.pet = pet
        navigationItem.title = pet.name
       collectionView?.reloadData()
      
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


    func setupCollectionView() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ProfileCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell3")
//        collectionView?.register(SubscriptionCell.self, forCellWithReuseIdentifier: subscriptionCellId)
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
    
    
    // Mohamed - to highligh menu bar when selected
    
    
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

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        }
        

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell3", for: indexPath)
        cell.backgroundColor = UIColor.blue

        return cell

        
        
   }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 120)
    }
}


class ActivityCell: BaseCell {
    override func setupViews() {
        self.backgroundColor = UIColor.green

    }
}


class SafeZoneCell: BaseCell {
    override func setupViews() {
        self.backgroundColor = UIColor.blue
    }
}



