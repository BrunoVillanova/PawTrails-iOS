//
//  QuestionsViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 19/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController {
    var pet: Pet!
    
    

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.register(questionCells.self, forCellWithReuseIdentifier: "cell")
        
        self.navigationItem.title = "Recommandation"
        collectionView.contentInset.left = 15
        collectionView.contentInset.right = 15
        collectionView.allowsMultipleSelection = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        collectionView.isScrollEnabled = false
    }
}


extension QuestionsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! questionCells
        
        if indexPath.item == 0 {
            cell.actionImage.image = UIImage(named: "tick")
        } else {
            cell.actionImage.image = UIImage(named: "untick")
        }
        
        cell.checkMark.isEnabled = false
        cell.checkMark.isUserInteractionEnabled = false
        cell.checkMark.setOn(false, animated: false)

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 145, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let cell = collectionView.cellForItem(at: indexPath) as! questionCells
            cell.checkMark.setOn(true, animated: false)
            performSegue(withIdentifier: "yes", sender: self)

        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! questionCells
            cell.checkMark.setOn(true, animated: false)
            performSegue(withIdentifier: "no", sender: self)

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let cell = collectionView.cellForItem(at: indexPath) as! questionCells
            cell.checkMark.setOn(false, animated: false)
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! questionCells
            cell.checkMark.setOn(false, animated: false)
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "yes"{
            if let destination = segue.destination as? YesViewController{
                destination.pet = self.pet
            }
        } else if segue.identifier == "no" {
            if let destination = segue.destination as? NoViewController{
                destination.pet = self.pet
            }
        }
    }
    
    
}



