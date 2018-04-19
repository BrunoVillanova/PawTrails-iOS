//
//  TermsViewController.swift
//  PawTrails
//
//  Created by Abhijith on 19/04/2018.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    var dataArray : NSArray?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let path = Bundle.main.path(forResource: "PrivacyTerms", ofType: "plist")
        dataArray = NSArray(contentsOfFile: path!)
        
        let topInset = 20;
        tableView.contentInset =  UIEdgeInsetsMake(CGFloat(topInset), 0, 0, 0);
        configureNavBar()
        
    }
    
    private func configureNavBar() {
        
        self.title = "Legal"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 18)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = PTConstants.colors.darkGray
    }
    
    @objc private func backButtonTapped() {
        
        //This VC used for both push and present.so handle the removal accordingly.
        if let count = self.navigationController?.viewControllers.count {
            if count > 1 {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension TermsViewController: UITableViewDelegate, UITableViewDataSource {
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return (dataArray?.count)!
    }
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
     func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TermsCell{
            
            if let data = dataArray {
                
                let dict = data[indexPath.section] as! NSDictionary
                if let text = dict.object(forKey: "description") as? String {
                    
                    let myParagraphStyle = NSMutableParagraphStyle()
                    myParagraphStyle.lineSpacing = 5
                    let myNsAttrStringObject = NSAttributedString.init(string: text, attributes: [NSParagraphStyleAttributeName: myParagraphStyle])
                    
                    cell.descriptionLabel.attributedText = myNsAttrStringObject
                }
            
                
            }
            
            //cell.bgView.dropShadow(color: .lightGray, opacity: 0.5, offSet: CGSize(width: 1, height: 1), radius: 3, scale: true)
            cell.bgView.layer.cornerRadius = 5
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nothing", for: indexPath)
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.clear
        let titleLabel = UILabel(frame: CGRect(x:10,y:-5,width:350,height:25))
        titleLabel.font = UIFont(name: "Monserrat-Regular", size: 22)
        if let data = dataArray {
            let dict = data[section] as! NSDictionary
            titleLabel.text  = dict.object(forKey: "title") as? String
        }
        
        vw.addSubview(titleLabel)

        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 25
    }
    
}

class TermsCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
}
