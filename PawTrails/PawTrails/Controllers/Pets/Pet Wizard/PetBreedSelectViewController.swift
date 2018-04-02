//
//  PetBreedViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 31/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class PetBreedSelectViewController: PetWizardStepViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func nextButtonVisible() -> Bool {
        return true
    }
    
    fileprivate func initialize() {
        rightBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skipTapped))
        configureSearchTextField()
    }
    
    fileprivate func configureSearchTextField() {
        if let searchImage = UIImage(named: "SearchIcon") {
            let frame = CGRect(x: 0, y: 0, width: searchImage.size.width+16, height: searchImage.size.height)
            let searchImageView = UIImageView(frame: frame)
            searchImageView.contentMode = .center
            searchImageView.image = searchImage
            searchImageView.tintColor = PTConstants.colors.darkGray
            searchTextField.leftView = searchImageView
            searchTextField.leftViewMode = .always
            searchTextField.tintColor = PTConstants.colors.darkGray
        }

    }
    
    func skipTapped() {
        self.delegate?.goToNextStep()
    }
    
    @IBAction func crossBreedButtonTapped(_ sender: Any) {
        
    }
}
