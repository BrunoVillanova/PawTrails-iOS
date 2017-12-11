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
    
    var pet: Pet!
    var date: Date?
    
    
    
    let color = UIColor(red: 206.0/255.0, green: 19.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        self.automaticallyAdjustsScrollViewInsets = false
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .primary
        settings.style.buttonBarItemTitleColor = .primary
        settings.style.buttonBarItemFont = .systemFont(ofSize: 15)
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
        super.viewDidLoad()
        APIRepository.instance.loadPet(pet.id, callback: { (error, pet) in
            if error == nil, let pet = pet {
                self.pet = pet
            }
        })
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(addTapped(_sender:)))
        
        

        navigationItem.title = pet.name
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    func addTapped(_sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "editPetDetails", sender: self)
  
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
        let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetInfromationViewController") as! PetInfromationViewController
        child_1.pet = self.pet
        let SafeZoneViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GoalsViewController") as! GoalsViewController
        SafeZoneViewController.pet = self.pet
        
        let child_3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SafeZoneViewController") as! SafeZoneViewController
        child_3.pet = self.pet
        
        let child_4 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdventuresListViewController") as! AdventuresListViewController
        child_4.pet = self.pet
        return [child_1, SafeZoneViewController, child_3, child_4]
    }

}
