//
//  SelectPetForRecommandationController.swift
//  PawTrails
//
//  Created by Marc Perello on 18/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit



class SelectPetForRecommandationController: UIViewController {
    
    @IBOutlet weak var startbtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate let presenter = PetsPresenter()
    var refreshControl = UIRefreshControl()

    fileprivate var pets = [Int:IndexPath]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        refreshControl.backgroundColor = UIColor.secondary
        refreshControl.tintColor = UIColor.primary
        refreshControl.addTarget(self, action: #selector(reloadPetsAPI), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        startbtn.layer.cornerRadius = 20
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false

        
        
        presenter.attachView(self)

    }
    
    @objc func reloadPetsAPI(){
        presenter.loadPets()
    }
    
    deinit {
        presenter.deteachView()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.allowsMultipleSelection = false
        startbtn.isEnabled = false
        startbtn.backgroundColor = UIColor.gray

        clearOnAppearance()
        reloadPets()
        presenter.startPetsListUpdates()
        if var selectedItem = collectionView.indexPathsForSelectedItems {
            selectedItem.removeAll()
        } else {
            print("No index were found")
        }
        

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        clearOnAppearance()
        if var selectedItem = collectionView.indexPathsForSelectedItems {
            selectedItem.removeAll()
        } else {
            print("No index were found")
        }

    }
    
    

    @IBAction func closeBtnPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func startBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "show", sender: self)
        clearOnAppearance()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show"{
            if let destination = segue.destination as? QuestionsViewController{
                
                if let index = self.collectionView.indexPathsForSelectedItems?.first {
                    let pet = presenter.pets[index.item]
                    destination.pet = pet
                  
                    clearOnAppearance()
                    self.startbtn.isEnabled = false
                }
            }
        }
    }
    
  
}





extension SelectPetForRecommandationController: PetsView {
    
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
        collectionView.reloadData()
    }
    
    func petsNotFound() {
        refreshControl.endRefreshing()
        collectionView.reloadData()
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

}

extension SelectPetForRecommandationController:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func clearOnAppearance() {
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if presenter.pets.isEmpty != true {
            return presenter.pets.count
        } else {
            return 0
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelectPetsCell
        if presenter.pets.isEmpty != true {
            let pet = presenter.pets[indexPath.item]
            cell.petTitle.text = pet.name
            if let imageData = pet.image as Data? {
                cell.petImage.image = UIImage(data: imageData)
            }else{
                cell.petImage.image = nil
            }
            cell.petImage.circle()
            cell.checkMarkView.isEnabled = false
            cell.checkMarkView.isUserInteractionEnabled = false
        } else {
            cell.petTitle.text = ""
            cell.petImage.image = UIImage(named: "")
        }

       return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SelectPetsCell
        let pet = presenter.pets[indexPath.item]
        print("fsdfsdf\(pet)")
        cell.checkMarkView.setOn(true, animated: true)
        self.startbtn.isEnabled = true
        self.startbtn.backgroundColor = UIColor.primary
}
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SelectPetsCell
        cell.checkMarkView.setOn(false, animated: true)
    }
 

    
    
    
    
    
}
