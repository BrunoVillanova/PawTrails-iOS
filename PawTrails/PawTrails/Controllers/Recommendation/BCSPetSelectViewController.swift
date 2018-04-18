//
//  BCSPetSelectViewController.swift
//  PawTrails
//
//  Created by Abhijith on 17/04/2018.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class BCSPetSelectViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startbtn: UIButton!
    fileprivate let presenter = PetsPresenter()
    fileprivate var pets = [Int:IndexPath]()
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigatonBar()
        
        refreshControl.backgroundColor = UIColor.secondary
        refreshControl.tintColor = UIColor.primary
        refreshControl.addTarget(self, action: #selector(reloadPetsAPI), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        presenter.attachView(self)
        
        reloadPetsAPI()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadPetsAPI(){
        presenter.loadPets()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
        presenter.deteachView()
    }
    
    fileprivate func configureNavigatonBar() {
        
        if presentingViewController != nil {
            let closeButton = UIBarButtonItem(image: UIImage(named: "close_icon"), style: .plain, target: self, action: #selector(closeButtonTapped))
            self.navigationItem.rightBarButtonItem = closeButton
            self.navigationItem.rightBarButtonItem?.tintColor = PTConstants.colors.darkGray
        }
        
        self.title = "Recommendations"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 14)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc private func closeButtonTapped() {
        
        self.dismiss(animated: true, completion: nil)
    }

}



extension BCSPetSelectViewController: PetsView {
    
    func reloadPets(){
        presenter.getPets()
    }
    
    func errorMessage(_ error: ErrorMsg) {
        //refreshControl.endRefreshing()
        alert(title: error.title, msg: error.msg)
    }
    
    func loadPets() {
        //refreshControl.endRefreshing()
        collectionView.reloadData()
    }
    
    func petsNotFound() {
        //refreshControl.endRefreshing()
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

extension BCSPetSelectViewController:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func clearOnAppearance() {
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if presenter.ownedPets.isEmpty != true {
            return presenter.ownedPets.count
        } else {
            return 0
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelectPetsCell
        if presenter.ownedPets.isEmpty != true {
            let pet = presenter.ownedPets[indexPath.item]
            cell.petTitle.text = pet.name
            cell.petImage.imageUrl = pet.imageURL
            cell.checkMarkView.isEnabled = false
            cell.checkMarkView.isUserInteractionEnabled = false
            cell.checkMarkView.setOn(false, animated: false)
        } else {
            cell.petTitle.text = ""
            cell.petImage.image = UIImage(named: "")
        }
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SelectPetsCell
        cell.checkMarkView.setOn(true, animated: true)
        self.startbtn.isEnabled = true
        self.startbtn.backgroundColor = UIColor.primary
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SelectPetsCell
        cell.checkMarkView.setOn(false, animated: true)
    }
    
    
    
}

