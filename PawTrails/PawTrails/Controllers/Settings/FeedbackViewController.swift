//
//  FeedbackViewController.swift
//  PawTrails
//
//  Created by Abhijith on 19/04/2018.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var feedbackTextField : UITextView!
    @IBOutlet weak var sendbutton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        feedbackTextField.layer.cornerRadius = 4
        
        Utilities.showComingSoonAlert("Feedback")
        feedbackTextField.dropShadow(color: .lightGray, opacity: 0.5, offSet: CGSize(width: 1, height: 1), radius: 3, scale: true)
        configureNavBar()
    }
    
    private func configureNavBar() {
        
        self.title = "Feedback"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 18)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = PTConstants.colors.darkGray
    }
    
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapSendButton(){
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
