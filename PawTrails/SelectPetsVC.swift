//
//  SelectPetsVC.swift
//  PawTrails
//
//  Created by Marc Perello on 04/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SelectPetsVC: UIViewController {

    @IBOutlet weak var startAdventureBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        startAdventureBtn.fullyroundedCorner()
        startAdventureBtn.backgroundColor = UIColor.primary
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true

    }

    @IBAction func closebtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
