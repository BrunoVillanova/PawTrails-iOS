//
//  PetsViewController.swift
//  Snout
//
//  Created by Marc Perello on 10/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetsViewController: UIViewController, PetsView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    fileprivate let presenter = PetsPresenter()
    
    fileprivate var pets = [Pet]()
    fileprivate var user:User!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        presenter.getPetsAndUser()
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - PetsView

    func errorMessage(_ error: errorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func petsNotFound() {
        //
    }
    
    func reload(_ user: User, _ pets: [Pet]) {
        self.user = user
        self.pets = pets
        self.collectionView.reloadData()
        self.navigationBar.title = user.name
    }
    
    func editProfile(){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController {
           self.present(vc, animated: true, completion: nil)
        }
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pets.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! userCell
            cell.layer.cornerRadius = 5
            cell.clipsToBounds =  true
            cell.imageView.layer.cornerRadius = 5
            cell.imageView.clipsToBounds = true
            cell.EditProfile.addTarget(self, action: #selector(PetsViewController.editProfile), for: .touchUpInside)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! petCell
            cell.titleLabel.text = pets[indexPath.row - 1].name
            cell.layer.cornerRadius = 5
            cell.clipsToBounds =  true
            return cell
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fit2 = (self.screenWidth - (15*3))/2
        return indexPath.row == 0 ? CGSize(width: (self.screenWidth - 30), height: 130) :  CGSize(width: fit2, height: fit2)
    }
    
}

class petCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var track: UIButton!
}

class userCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var EditProfile: UIButton!
}
