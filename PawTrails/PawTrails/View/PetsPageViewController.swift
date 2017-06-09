//
//  PetsPageViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 03/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetsPageViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var topNavigationItem: UINavigationItem!
    @IBOutlet weak var profile: UIView!
    @IBOutlet weak var activity: UIView!
    
    var pet: Pet!
    var fromMap: Bool = false
    var activityEnabled: Bool = false

    var pages = [UIView]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        profile.alpha = 0.0
        activity.alpha = 0.0
        
        pages = [profile,activity]
        
        if activityEnabled {
            segmentControl.selectedSegmentIndex = 1
            enableView(at: 1)
        }else{
            enableView(at: 0)
        }
        
        if fromMap {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(dismissAction(sender: )))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        topNavigationItem.prompt = pet.name
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        
        enableView(at: sender.selectedSegmentIndex)
    }
    
    func enableView(at index: Int) {
        
        let view = self.pages[index]
        view.alpha = 0.0
        view.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 1.0
            for v in self.pages {
                if v != view {
                    v.alpha = 0.0
                }
            }
        }) { (done) in
            for v in self.pages {
                if v != view {
                    v.isHidden = true
                }
            }

        }
    }
    
    var profileTableViewController: PetProfileTableViewController? {
        return childViewControllers.first(where: { $0 is PetProfileTableViewController }) as? PetProfileTableViewController
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case is PetProfileTableViewController: (segue.destination as! PetProfileTableViewController).pet = pet
        case is PetActivityViewController: (segue.destination as! PetActivityViewController).pet = pet
        default: break
        }
    }

}
























