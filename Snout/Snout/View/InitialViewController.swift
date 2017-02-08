//
//  InitialViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    fileprivate let presenter = InitialPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
    }

}

extension InitialViewController: InitialView {
    
    func errorMessage(_ error: String) {
        self.alert(title: "Warning", msg: error)
    }
    
}
