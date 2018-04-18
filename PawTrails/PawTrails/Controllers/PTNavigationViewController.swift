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
    var showNavigationBarDropShadow: Bool = false {
        didSet {
            setupShadow(showNavigationBarDropShadow)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       initialize()
    }
    
    override var viewControllers: [UIViewController] {
        didSet {
            setupShadow(false)
            addLeftMenuButton()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
        self.navigationBar.shadowImage = UIImage()
        
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
    
    fileprivate func addLeftMenuButton() {
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "LeftMenuIcon"), style: .plain, target: self, action: #selector(leftMenuAction))
        leftBarButton.tintColor = PTConstants.colors.darkGray
        self.navigationBar.topItem?.leftBarButtonItem = leftBarButton
    }
    
    fileprivate func setupShadow(_ enabled: Bool) {
        if enabled {
            self.navigationBar.layer.shadowColor = PTConstants.colors.darkGray.cgColor
            self.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 10)
            self.navigationBar.layer.shadowRadius = 10
            self.navigationBar.layer.shadowOpacity = 0.09
            self.navigationBar.layer.masksToBounds = false
        } else {
            self.navigationBar.layer.shadowOpacity = 0
        }
    }
}
