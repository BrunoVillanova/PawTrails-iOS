//
//  HomeViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    fileprivate let presenter = HomePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
    }
    
    @IBAction func signOutAction(_ sender: UIBarButtonItem) {
        self.presenter.signOut()
    }
    
}

extension HomeViewController: HomeView{
    
    func errorMessage(_ error: String) {
        self.alert(title: "Error", msg: error)
    }
    
    func userNotSignedIn() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
