//
//  InitialViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, InitialView {

    fileprivate let presenter = InitialPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
    }
    
    @IBAction func FBAction(_ sender: UIButton) {
    }
    
    // MARK: - Initial View
    
    func errorMessage(_ error: errorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func loggedSocialMedia() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
