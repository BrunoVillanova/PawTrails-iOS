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
    
    @IBOutlet weak var watchNow: UIButton!
    
    @IBAction func watchNowBtnPressed(_ sender: Any) {
        self.popUpDestructive(title: "", msg: "You are being redirected to youtube to watch the Tutorial", cancelHandler: nil) { (done) in
            let youtubeId = "C9ng5Dw8kIU"
            if let urlFromStr = URL(string: "youtube://\(youtubeId)") {
                if UIApplication.shared.canOpenURL(urlFromStr) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(urlFromStr, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(urlFromStr)
                    }
                } else if let webURL = URL(string: "https://www.youtube.com/watch?v=C9ng5Dw8kIU") {
                    UIApplication.shared.openURL(webURL)
                }
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        watchNow.backgroundColor = UIColor.primary
        watchNow.round()
        watchNow.setTitle("Video Tutorial", for: .normal)
        watchNow.setTitleColor(UIColor.white, for: .normal)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.navigationItem.title = "Recommendations"
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
            return CGSize(width: 100, height: 175)

    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
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



