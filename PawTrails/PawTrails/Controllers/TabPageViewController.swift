//
//  TabPageViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 02/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TabPageViewController: ButtonBarPagerTabStripViewController {
    
    let color = UIColor(red: 206.0/255.0, green: 19.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    var pet: Pet!
    var date: Date?
    var iphoneX = false
    
    override func viewDidLoad() {
        
        initialize()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            if ((UIApplication.shared.keyWindow?.safeAreaInsets.top)! > CGFloat(0.0)) {
                iphoneX = true
                Reporter.debugPrint("iPhone X")
            } else {
                self.tabBarController?.tabBar.isHidden = true
            }
        }

    }
    
    fileprivate func configureLayout() {
        
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.title = pet.name
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .primary
        settings.style.buttonBarItemTitleColor = .primary
        settings.style.buttonBarItemFont = UIFont(name: "Roboto-Medium", size:14)!
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.color
        }
        
        if pet.isOwner {
            self.navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped(_:)))
        }
    }
    
    fileprivate func initialize() {
        configureLayout()
        
        APIRepository.instance.loadPet(pet.id, callback: { (error, pet) in
            if error == nil, let pet = pet {
                self.pet = pet
            }
        })
    }
    
    @objc fileprivate func editTapped(_ sender: UIBarButtonItem) {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddEditPetDetailsTableViewController") as? AddEditPetDetailsTableViewController {
            if let pet = self.pet {
                vc.pet = pet
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
  
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPetDetails" {
            if let navigationController = segue.destination as? AddEditPetDetailsTableViewController {
                    if let pet = self.pet {
                        navigationController.pet = pet
                    }
            }
        }
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let petInfo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetInfromationViewController") as! PetInfromationViewController
        petInfo.pet = self.pet
        
        let goals = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GoalsViewController") as! GoalsViewController
        goals.pet = self.pet
        goals.date = Date()
        
        let safeZone = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SafeZoneViewController") as! SafeZoneViewController
        safeZone.pet = self.pet
        
        let adventureHistory = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdventuresListViewController") as! AdventuresListViewController
        adventureHistory.pet = self.pet
        
        return [petInfo, goals, adventureHistory, safeZone]
    }
}
