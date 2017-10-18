//
//  QuestionsViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 18/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController {
    
    var pet: Pet!

    @IBAction func btnPressed(_ sender: UIBarButtonItem) {
     self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
        }
    }
}
