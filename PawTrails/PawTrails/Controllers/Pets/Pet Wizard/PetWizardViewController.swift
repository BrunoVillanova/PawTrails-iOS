//
//  PetWizardNavigationViewController.swift
//  PawTrails
//
//  Created by Bruno on 28/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import Hero

//protocol PetWizardViewControllerDelegate {
//    func showNextButton() -> Bool
//}

class PetWizardViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var stepIndicatorLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var footerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    
    final let steps = ["connectDevice", "nameAndPhoto", "type", "breed", "genderAndNeuter", "birthdayAndWeight", "final"]
    
    var stepsViewControllers = [PetWizardStepViewController]()
    var currentStepIndex: Int = 0
    var currentChildViewController: PetWizardStepViewController?
    var pet: Pet?
    var showNextButton: Bool = false
//    {
//        didSet {
//            if showNextButton != oldValue {
//                let newHeight: CGFloat = showNextButton ? 48 : 0
//                footerViewHeightConstraint.constant = newHeight
//            }
//        }
//    }
    
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
        
//        if let currentChildViewController = currentChildViewController {
//            self.showNextButton = currentChildViewController.nextButtonVisible()
//        }
        guard currentChildViewController != nil else {
            return
        }
        
        let index = stepsViewControllers.index(of: currentChildViewController!)!
        
        stepIndicatorLabel.text = "Step \(index+1) - \(steps.count)"
        
        if currentChildViewController != stepsViewControllers.first {
            self.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
            self.navigationBar.topItem?.leftBarButtonItem?.tintColor = PTConstants.colors.darkGray
            
            let title = "Cancel"
            let action = #selector(cancelWizard)
            
            let rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
            
//            if let currentChildViewController = currentChildViewController, let vcRightBarButtonItem = currentChildViewController.rightBarButtonItem {
//                rightBarButtonItem = vcRightBarButtonItem
//            }
    
            var titleTextAttributes = [
                NSFontAttributeName : UIFont(name: "Montserrat-Regular", size: 14)!,
                NSForegroundColorAttributeName : PTConstants.colors.newRed,
                ]
            
            rightBarButtonItem.setTitleTextAttributes(titleTextAttributes, for: .normal)
            
            titleTextAttributes[NSFontAttributeName] = UIFont(name: "Montserrat-Medium", size: 14)!
            rightBarButtonItem.setTitleTextAttributes(titleTextAttributes, for: .highlighted)
      
            self.navigationBar.topItem?.rightBarButtonItem = rightBarButtonItem
            self.navigationBar.topItem?.rightBarButtonItem?.tintColor = PTConstants.colors.newRed
            
        } else {
            self.navigationBar.topItem?.leftBarButtonItem = nil
            self.navigationBar.topItem?.rightBarButtonItem = nil
        }
    }
    
    func backButtonTapped() {
        self.goToStep(currentStepIndex-1)
    }
    
    fileprivate func goToStep(_ index: Int) {
        
        if steps.count > index, let storyboard = self.storyboard {
            
            if index == steps.count-1, let pet = self.pet, pet.id <= 0 {
                registerPet()
                return
            }
            
            var viewController: PetWizardStepViewController?
            
            if stepsViewControllers.count > index {
                viewController = stepsViewControllers[index]
            } else  {
                viewController = storyboard.instantiateViewController(withIdentifier: steps[index]) as? PetWizardStepViewController
                viewController!.delegate = self
                viewController!.pet = pet!
                stepsViewControllers.append(viewController!)
            }
            
            if currentChildViewController == nil {
                 self.add(asChildViewController: viewController!)
                 updateUI()
            } else {
                cycleViewControllers(currentViewController: currentChildViewController!, nextViewController: viewController!)
            }
            currentStepIndex = index
        }
    }
    
    fileprivate func registerPet() {
        if let pet = self.pet {
            self.showLoadingView()
            DataManager.instance.register(pet, callback: { (error, pet) in
                self.hideLoadingView()
                if let error = error {
                    self.showMessage(error.msg.msg, type: .error)
                } else {
                    self.pet = pet
                    self.uploadPetImageIfNeeded()
                }
            })
        }
    }
    
    fileprivate func uploadPetImageIfNeeded() {
        if let pet = self.pet, let petImageData = pet.image {
            self.showLoadingView()
            DataManager.instance.savePet(image: petImageData, into: pet.id, callback: { (error) in
                self.hideLoadingView()
                self.goToStep(self.currentStepIndex)
                if let error = error {
                    self.showMessage(error.msg.msg, type: .error)
                } else {
                    self.uploadPetImageIfNeeded()
                }
            })
        } else {
            self.goToStep(self.currentStepIndex)
        }
    }
    
    fileprivate func cycleViewControllers(currentViewController: PetWizardStepViewController, nextViewController: PetWizardStepViewController) {
        
        currentViewController.hero.isEnabled = false
        currentViewController.view.hero.id = "step"
        nextViewController.view.hero.modifiers = [.translate(x: -100.0), .scale(0.5)]
        nextViewController.view.hero.id = "step"
        nextViewController.hero.isEnabled = true
        
        // Prepare the two view controllers for the change.
        currentViewController.willMove(toParentViewController: nil)
        addChildViewController(nextViewController)
        
        // Configure Child View
        nextViewController.view.alpha = 0
        nextViewController.view.frame = contentView.bounds
        nextViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if !nextViewController.nextButtonVisible()  {
            self.footerViewHeightConstraint.constant = 0

            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }
        
        self.currentChildViewController = nextViewController
        
        self.transition(from: currentViewController, to: nextViewController, duration: 0.2, options: .layoutSubviews, animations: {
            currentViewController.view.alpha = 0
            nextViewController.view.alpha = 1
            self.updateUI()
        }) { (finished) in
            
            if finished {
                currentViewController.removeFromParentViewController()
                nextViewController.didMove(toParentViewController: self)
                
                if nextViewController.nextButtonVisible()  {
                    self.footerViewHeightConstraint.constant = 48

                    UIView.animate(withDuration: 0.1) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    fileprivate func removeCurrentChildViewControllerIfNeeded() {
        if let currentChildViewController = currentChildViewController {
            self.remove(asChildViewController: currentChildViewController)
        }
    }
    
    fileprivate func add(asChildViewController viewController: PetWizardStepViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Configure Child View
        viewController.view.frame = contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add Child View as Subview
        contentView.addSubview(viewController.view)
        
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
    
    func cancelWizard() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        self.goToStep(currentStepIndex+1)
    }
}

extension PetWizardViewController: PetWizardStepViewControllerDelegate {
    
    func stepCompleted(completed: Bool, pet: Pet) {
        self.pet! = pet
        self.nextButton.isEnabled = completed
    }

    func stepCanceled(pet: Pet) {
        cancelWizard()
    }
    
    func goToNextStep() {
        self.goToStep(currentStepIndex+1)
    }
    
    func getPet() -> Pet? {
        return self.pet
    }
    
    func updatePet(_ pet: Pet?) {
        self.pet = pet
    }
}
