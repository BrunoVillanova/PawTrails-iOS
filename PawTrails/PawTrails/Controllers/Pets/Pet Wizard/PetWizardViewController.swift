//
//  PetWizardNavigationViewController.swift
//  PawTrails
//
//  Created by Bruno on 28/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

//public protocol PetWizardStep {
//    func petUpdated(pet: Pet)
//}

class PetWizardViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var stepIndicatorLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    final let steps = ["connectDevice", "nameAndPhoto"]
    
    var stepsViewControllers = [PetWizardStepViewController]()
    var currentStepIndex: Int = 0 {
        didSet {
            self.goToStep(currentStepIndex)
        }
    }
    var currentChildViewController: UIViewController?
    var pet: Pet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
        configureNavigatonBar()
        
        if pet == nil {
            pet = Pet()
        }
        goToStep(currentStepIndex)
    }
    
    fileprivate func goToStep(_ index: Int) {
        
        if steps.count > index, let storyboard = self.storyboard {
            
            self.removeCurrentChildViewControllerIfNeeded()
            
            var viewController: PetWizardStepViewController?
            
            if stepsViewControllers.count > index {
                viewController = stepsViewControllers[index]
            } else  {
                viewController = storyboard.instantiateViewController(withIdentifier: steps[index]) as? PetWizardStepViewController
                viewController!.delegate = self
                viewController!.pet = pet!
                stepsViewControllers.append(viewController!)
            }
        
            self.add(asChildViewController: viewController!)
            updateUI()
        }
    }
    
    fileprivate func configureNavigatonBar() {
        // Transparent navigation bar
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.backgroundColor = UIColor.clear
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.topItem?.title = " "
        self.navigationBar.backItem?.title = " "
    }
    
    fileprivate func updateUI() {
        stepIndicatorLabel.text = "Step \(currentStepIndex+1) - \(steps.count)"
        
        if currentStepIndex > 0 {
            self.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
            self.navigationBar.topItem?.leftBarButtonItem?.tintColor = PTConstants.colors.darkGray
        } else {
            self.navigationBar.topItem?.leftBarButtonItem = nil
        }
    }
    
    func backButtonTapped() {
        self.currentStepIndex = self.currentStepIndex - 1
    }
    
    //    fileprivate func configureNavigationBar() {
    //        if self.presentingViewController != nil {
    //            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close-1x-png"), style: .plain, target: self, action: #selector(closeButtonTapped))
    //            self.navigationItem.leftBarButtonItem?.tintColor = .darkGray
    //        }
    //
    //        self.navigationItem.title = "Adventure Result"
    //    }
    
    fileprivate func removeCurrentChildViewControllerIfNeeded() {
        if let currentChildViewController = currentChildViewController {
            self.remove(asChildViewController: currentChildViewController)
        }
    }
    
    fileprivate func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        contentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
        currentChildViewController = viewController
    }
    
    fileprivate func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
}

extension PetWizardViewController: PetWizardStepViewControllerDelegate {
    
    func stepCompleted(pet: Pet) {
        self.currentStepIndex = self.currentStepIndex + 1
    }
    
    func stepCanceled(pet: Pet) {
        self.dismiss(animated: true, completion: nil)
    }
}
