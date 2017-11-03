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
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named:"switch-device-button-1x-png"), style: .plain, target: self, action: #selector(addTapped(_sender:)))

        navigationItem.title = pet.name
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    func addTapped(_sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ChangeDevice", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeDevice" {
            if let navigationController = segue.destination as? UINavigationController {
                if let childVC = navigationController.topViewController as? AddPetDeviceTableViewController {
                    if let petid = self.pet {
                        childVC.petId = petid.id
                    }
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
        
        return [child_1, SafeZoneViewController, child_3]
    }

}
