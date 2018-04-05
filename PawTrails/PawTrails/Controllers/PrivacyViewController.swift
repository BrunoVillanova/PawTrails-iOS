//
//  PrivacyViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 04/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureNavigatonBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneActionBtn(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func configureNavigatonBar() {
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "BackIcon"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(backButtonTapped), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33, height: 27)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.title = "Legal"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 14)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
    
    func backButtonTapped() {
        
        self.navigationController?.popViewController(animated: true)
    }
 

}
