//
//  SuccessViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 15/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    
    @IBOutlet weak var suceessbtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        suceessbtn.round()
        self.navigationController?.navigationBar.topItem?.title = " "
    }
    
    @IBAction func sucessBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
