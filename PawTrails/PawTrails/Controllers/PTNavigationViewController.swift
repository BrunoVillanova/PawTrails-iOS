//
//  PTNavigationViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 09/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SideMenu

class PTNavigationViewController: UINavigationController {

    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
       initialize()
    }
    
    override var viewControllers: [UIViewController] {
        didSet {
            let leftBarButton = UIBarButtonItem(image: UIImage(named: "LeftMenuIcon"), style: .plain, target: self, action: #selector(leftMenuAction))
            leftBarButton.tintColor = PTConstants.colors.darkGray
            self.navigationBar.topItem?.leftBarButtonItem = leftBarButton
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
        
        if SideMenuManager.default.menuLeftNavigationController == nil {
            SideMenuManager.default.menuLeftNavigationController = ViewController.leftMenu.viewController as? UISideMenuNavigationController
            SideMenuManager.default.menuAnimationBackgroundColor = .clear
            SideMenuManager.default.menuPresentMode = .menuSlideIn
            SideMenuManager.default.menuAnimationFadeStrength = 0.5
        }
        
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
    }
    
    func leftMenuAction() {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
}
