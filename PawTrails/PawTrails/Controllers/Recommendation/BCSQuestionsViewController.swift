//
//  BCSQuestionsViewController.swift
//  PawTrails
//
//  Created by Abhijith on 17/04/2018.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class BCSQuestionsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var totalitems = 1
    var currentIndex = 0
    var data : NSMutableDictionary?
    var currentData : NSMutableDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureNavigatonBar()
        
        data = BCSDataManager.getAllQuestions()
        currentData = data
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func configureNavigatonBar() {
        
        if presentingViewController != nil {
            let closeButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeButtonTapped))
            closeButton.tintColor = PTConstants.colors.newRed
            self.navigationItem.rightBarButtonItem = closeButton
            self.navigationItem.backBarButtonItem?.tintColor = PTConstants.colors.darkGray
        }
        
        self.title = "Body Condition Score"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 18)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = PTConstants.colors.darkGray
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //Set shadow
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.5
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    func closeButtonTapped() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func yesButtonAction() {
        
        currentIndex += 1
        //currentData?.removeAllObjects()
        currentData = currentData?["yes"] as? NSMutableDictionary
        self.collectionView.scrollToItem(at:IndexPath(item: currentIndex, section: 0), at: .right, animated: true)
        
        debugPrint(currentData!)
        
    }
    
    @IBAction func noButtonAction() {
        
        currentIndex += 1
        //let temp = currentData?["no"] as? NSMutableDictionary
        //currentData?.removeAllObjects()
        currentData = currentData?["no"] as? NSMutableDictionary
        self.collectionView.scrollToItem(at:IndexPath(item: currentIndex, section: 0), at: .right, animated: true)
        
        debugPrint(currentData!)
        
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

extension BCSQuestionsViewController:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BCSQuestionCell
        
        if let data = currentData {
            
            if let title = data["title"] as? String {
                cell.titleLabel.text = title
            }
            
            if let question = data["question"] as? String {
                cell.descriptionlabel.text = question
            }
        }
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        
    }
}

class BCSDataManager {
    
    class func getAllQuestions()-> NSMutableDictionary? {
        
        var myDict: NSMutableDictionary?
        if let path = Bundle.main.path(forResource: "BCSScore", ofType: "plist") {
            myDict = NSMutableDictionary(contentsOfFile: path)
        }
        
        return myDict
    }
    
}


class BCSQuestionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionlabel: UILabel!
}



