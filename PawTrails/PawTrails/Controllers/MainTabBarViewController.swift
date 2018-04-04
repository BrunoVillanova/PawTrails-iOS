//
//  MainTabBarViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 18/12/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift

class MainTabBarViewController: UITabBarController {

    let disposeBag = DisposeBag()
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabBar.invalidateIntrinsicContentSize()
    }
    

    fileprivate func initialize() {

    }

}
