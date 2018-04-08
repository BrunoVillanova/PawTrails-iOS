//
//  PasswordRecoverySuccessViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 04/07/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class PasswordRecoverySuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigatonBar()
    }
    
    fileprivate func configureNavigatonBar() {
        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.backItem?.title = " "
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToLoginAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
