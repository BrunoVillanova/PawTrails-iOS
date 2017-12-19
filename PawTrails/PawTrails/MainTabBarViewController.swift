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

        guard !SignUpYourDeviceVC.tutorialShown() else {
            return
        }
        
        DataManager.instance.pets().subscribe(onNext: { (pets) in
            #if DEBUG
            let root = self.storyboard?.instantiateViewController(withIdentifier: "SignUpYourDeviceVC") as! SignUpYourDeviceVC
            let navigationController = UINavigationController.init(rootViewController: root)
            self.present(navigationController, animated: true, completion: nil)
            #else
            if pets.isEmpty || pets.count == 0 {
                let root = self.storyboard?.instantiateViewController(withIdentifier: "SignUpYourDeviceVC") as! SignUpYourDeviceVC
                let navigationController = UINavigationController.init(rootViewController: root)
                self.present(navigationController, animated: true, completion: nil)
            }
            #endif
        }).disposed(by: disposeBag)
    }

}
