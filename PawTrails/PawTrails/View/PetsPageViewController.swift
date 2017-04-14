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
    @IBOutlet weak var zones: UIView!
    @IBOutlet weak var users: UIView!
    
    var pet: String!
    
    var pages = [UIView]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        topNavigationItem.prompt = pet
        
        pages = [profile,activity,zones,users]
        enableView(at: 1)
        
//        navigationController?.navigationBar.topItem?.title =
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
}
























