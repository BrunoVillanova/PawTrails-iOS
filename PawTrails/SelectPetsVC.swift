//
//  SelectPetsVC.swift
//  PawTrails
//
//  Created by Marc Perello on 04/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit



struct petIds {
    static var Ids = [Int]()
}


class SelectPetsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PetsView {
    @IBOutlet weak var petsCollectionView: UICollectionView!
    @IBOutlet weak var startAdventureBtn: UIButton!
    
    var refreshControl = UIRefreshControl()
    
    fileprivate let presenter = PetsPresenter()
    fileprivate var pets = [Int:IndexPath]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startAdventureBtn.isEnabled = false
        
        startAdventureBtn.fullyroundedCorner()
        startAdventureBtn.backgroundColor = UIColor.primary
        
        
        refreshControl.backgroundColor = UIColor.secondary
        refreshControl.tintColor = UIColor.primary
        refreshControl.addTarget(self, action: #selector(reloadPetsAPI), for: .valueChanged)
        petsCollectionView.addSubview(refreshControl)
        
        
        UIApplication.shared.statusBarStyle = .lightContent
        presenter.attachView(self)
        
        petsCollectionView.delegate = self
        petsCollectionView.dataSource = self
        petsCollectionView.allowsMultipleSelection = true
        
 
        clearOnAppearance()
        
        

}
    
    
    
    func clearOnAppearance() {
        for indexPath in petsCollectionView.indexPathsForSelectedItems ?? [] {
            petsCollectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    @objc func reloadPetsAPI(){
        presenter.loadPets()
    }
    
    deinit {
        presenter.deteachView()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        petIds.Ids.removeAll()

        reloadPets()
        presenter.startPetsListUpdates()
        presenter.startPetsGPSUpdates { (id) in
            self.updateRow(by: id)
        }
        presenter.startPetsGeocodeUpdates { (geocode) in
            self.updateRow(by: geocode.id)
        }

    }
    
    
    
    private func updateRow(by id: Int){
        
        Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Update Pet \(id)")
        if let index = self.pets[id] {
            self.petsCollectionView.reloadItems(at: [index])
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        presenter.stopPetListUpdates()
        presenter.stopPetGPSUpdates()
        presenter.stopPetsGeocodeUpdates()
    }
    
    
    func reloadPets(){
        presenter.getPets()
    }
    
    
    // Mohamed - PetsView
    
    func errorMessage(_ error: ErrorMsg) {
        refreshControl.endRefreshing()
        alert(title: error.title, msg: error.msg)
    }

    func loadPets() {
        refreshControl.endRefreshing()
        petsCollectionView.reloadData()
    }

    func petsNotFound() {
        refreshControl.endRefreshing()
        petsCollectionView.reloadData()
    }

    
    // Mohamed: - UicollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return presenter.pets.count
    }
    
    func getPet(at indexPath: IndexPath) -> Pet {
        
        if presenter.pets.count > 0 {
            return presenter.pets[indexPath.item]
        }else if presenter.ownedPets.count > 0 {
            return presenter.ownedPets[indexPath.row]
        }else{
            return presenter.sharedPets[indexPath.row]
        }
    }
    
 

    
    
    
    
    

    

    // CollectionVIew Method
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelectPetsCell
        let pet = getPet(at: indexPath)
        pets[pet.id] = indexPath
        cell.petTitle.text = pet.name
        if let imageData = pet.image as Data? {
            cell.petImage.image = UIImage(data: imageData)
        }else{
            cell.petImage.image = nil
        }
        cell.petImage.circle()
        
        cell.checkMarkView.isEnabled = false
        cell.checkMarkView.isUserInteractionEnabled = false

        return cell
        
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
        let cell = collectionView.cellForItem(at: indexPath) as! SelectPetsCell
        cell.checkMarkView.setOn(true, animated: true)
        
        self.startAdventureBtn.isEnabled = true
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = petsCollectionView.cellForItem(at: indexPath) as! SelectPetsCell
        
        cell.checkMarkView.setOn(false, animated: true)
        
    }

    @IBAction func selectAllPressed(_ sender: Any) {
        for i in 0..<petsCollectionView.numberOfSections {
            for j in 0..<petsCollectionView.numberOfItems(inSection: i) {
                petsCollectionView.selectItem(at: IndexPath(row: j, section: i), animated: false, scrollPosition: .bottom)

            }
        }

        for i in 0..<petsCollectionView.numberOfSections {
            for j in 0..<petsCollectionView.numberOfItems(inSection: i) {
                let index = NSIndexPath(item: j, section: i)
                let cell = petsCollectionView.cellForItem(at: index as IndexPath) as! SelectPetsCell
                cell.checkMarkView.setOn(true, animated: true)
            }
        }

    }
    
 
    @IBAction func StartAdventureBtnPressed(_ sender: Any) {


        petIds.Ids.removeAll()
        if let indexpath = petsCollectionView.indexPathsForSelectedItems {
            for index in indexpath {
               let pets =  getPet(at: index)
                
                petIds.Ids.append(pets.id)
            }

            startMyTripNow(petIds.Ids)

         }
    }
    
    
    
    func startMyTripNow(_ petIds: [Int]){
        DataManager.instance.startMyAdventure(petIds) { (error, data) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("This an array of data \(String(describing: data))")
            }
        }
}

    @IBAction func closebtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


