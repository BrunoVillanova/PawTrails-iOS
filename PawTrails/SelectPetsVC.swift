//
//  SelectPetsVC.swift
//  PawTrails
//
//  Created by Marc Perello on 04/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SelectPetsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PetsView, SelectPetView {
    @IBOutlet weak var petsCollectionView: UICollectionView!
    @IBOutlet weak var startAdventureBtn: UIButton!

    var refreshControl = UIRefreshControl()
    
    fileprivate let presenter = PetsPresenter()
    fileprivate let presenter2 = SelectedPetView()

    
    fileprivate var pets = [Int:IndexPath]()
    var runningTripArray = [TripList]()
    var tripListArray = [Int]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startAdventureBtn.isEnabled = false
        startAdventureBtn.fullyroundedCorner()
        startAdventureBtn.backgroundColor = UIColor.primary
        APIRepository.instance.finishTrip(539, timeStamp: 1506075288) { (error, trips) in
            print("sucess")
        }

        
        
        refreshControl.backgroundColor = UIColor.secondary
        refreshControl.tintColor = UIColor.primary
        refreshControl.addTarget(self, action: #selector(reloadPetsAPI), for: .valueChanged)
        petsCollectionView.addSubview(refreshControl)
        
        
        UIApplication.shared.statusBarStyle = .lightContent
        presenter.attachView(self)
        presenter2.attatchView(self)
        
        petsCollectionView.delegate = self
        petsCollectionView.dataSource = self
        petsCollectionView.allowsMultipleSelection = true
        
        getRunningandPausedTrips()

}
    
    
    
    func getRunningandPausedTrips() {
        runningTripArray.removeAll()
        tripListArray.removeAll()
        APIRepository.instance.getTripList([0,1]) { (error, trips) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let trips = trips {
                    for trip in trips {
                        self.runningTripArray.append(trip)
                        
                    }
                    print("Print \(self.tripListArray)")
                }
            }
        }
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
        clearOnAppearance()
        self.tabBarController?.tabBar.isHidden = true
        reloadPets()
        presenter.startPetsListUpdates()
        presenter.startPetsGPSUpdates { (id) in
//            self.updateItem(by: id)
        }
        presenter.startPetsGeocodeUpdates { (geocode) in
            self.updateItem(by: geocode.id)
        }

        if var selectedItem = petsCollectionView.indexPathsForSelectedItems {
            selectedItem.removeAll()
        } else {
            print("No index were found")
        }

    }

    
    private func updateItem(by id: Int){
        Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Update Pet \(id)")
        if let index = self.pets[id] {
            self.petsCollectionView.reloadItems(at: [index])
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
//        presenter.stopPetListUpdates()
//        presenter.stopPetGPSUpdates()
//        presenter.stopPetsGeocodeUpdates()
//
    }
    override func viewDidDisappear(_ animated: Bool) {
        presenter2.tripList.removeAll()
        
        if var selectedItem = petsCollectionView.indexPathsForSelectedItems {
            selectedItem.removeAll()
        } else {
            print("No index were found")
        }

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
    
    
    func getPet(at indexPath: IndexPath) -> Pet {
        
        if presenter.pets.count > 0 {
            return presenter.pets[indexPath.item]
        }else if presenter.ownedPets.count > 0 {
            return presenter.ownedPets[indexPath.row]
        }else{
            return presenter.sharedPets[indexPath.row]
        }
    }

    
    // Mohamed: - UicollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.pets.count
    }
    


    // CollectionVIew Method
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelectPetsCell

        let pet = getPet(at: indexPath)
        pets[pet.id] = indexPath

            if tripListArray.contains(indexPath.item) {
                cell.backgroundColor = UIColor.brown
 
        } else {
            cell.petTitle.text = pet.name
            if let imageData = pet.image as Data? {
                cell.petImage.image = UIImage(data: imageData)
            }else{
                cell.petImage.image = nil
            }
            cell.petImage.circle()
                           cell.checkMarkView.isEnabled = false
            cell.checkMarkView.isUserInteractionEnabled = false

        }

        return cell
}


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! SelectPetsCell
        cell.checkMarkView.setOn(true, animated: true)

        let selectedPet = indexPath
        let pet = getPet(at: selectedPet).id
        for item in runningTripArray {
            tripListArray.append(item.petId)
        }
        if tripListArray.contains(pet) {
            
            cell.isUserInteractionEnabled = false
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.gray.cgColor
            self.alert(title: "Error", msg: "You cannot select this pet because it's already on trip", type: .red, disableTime: 4, handler: nil)
            cell.isSelected = false
            
            
            if var selected = petsCollectionView.indexPathsForSelectedItems {
                selected.remove(at: indexPath.item)
            }
            
            cell.checkMarkView.setOn(false, animated: true)
            self.startAdventureBtn.isEnabled = true
            

        } else {
            self.startAdventureBtn.isEnabled = true
        }
        
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
                var petIds = [Int]()
                petIds.removeAll()
                if let indexpath = petsCollectionView.indexPathsForSelectedItems {
                    for index in indexpath {
                       let pets =  getPet(at: index)
                        petIds.append(pets.id)
         
                    self.presenter2.startTrip(with: petIds)
                    performSegue(withIdentifier: "Segue", sender: self)
                    
                    }
                } else {
                    alert(title: "", msg: "Selected pets are already on trip, please try selecting different pet", type: .red, disableTime: 4, handler: nil)
        }
  
    }

    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue"  {
            if let navigationController = segue.destination as? UINavigationController {
                let vc = navigationController.topViewController as? TripScreenViewController
                vc?.tripList = self.presenter2.trips
            }
        }
    }

    
    
    
    @IBAction func closebtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}

