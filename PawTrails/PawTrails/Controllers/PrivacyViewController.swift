//
//  PrivacyViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 04/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.contentInset = UIEdgeInsetsMake(0, 16, 0, 16)
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
        
        if presentingViewController != nil {
            let closeButton = UIBarButtonItem(image: UIImage(named: "close_icon"), style: .plain, target: self, action: #selector(closeButtonTapped))
            self.navigationItem.rightBarButtonItem = closeButton
            self.navigationItem.rightBarButtonItem?.tintColor = PTConstants.colors.darkGray
        }
        
        
        self.title = "Legal"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 14)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
    
    func closeButtonTapped() {
        self.dismiss(animated: true)
    }
    
    func backButtonTapped() {
        
        self.navigationController?.popViewController(animated: true)
    }
 

}
