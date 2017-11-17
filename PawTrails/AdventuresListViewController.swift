//
//  AdventuresListViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 07/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import XLPagerTabStrip


class AdventuresListViewController: UIViewController, IndicatorInfoProvider  {
    var pet: Pet!
    
    @IBOutlet weak var distanceCircle: CircleChart!
    @IBOutlet weak var timeCircle: CircleChart!
    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    
    lazy var mydatePicker: AirbnbDatePicker = {
        let btn = AirbnbDatePicker()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.delegate = self
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let distanceColor = UIColor(red: 153/255, green: 202/255, blue: 186/255, alpha: 1)
        let timeColor = UIColor(red: 211/255, green: 100/255, blue: 59/255, alpha: 1)

        distanceCircle.setChart(at: 0.9, color: distanceColor, text: "Km")
        timeCircle.setChart(at: 0.5, color: timeColor, text: "min")
        
        editBtn.border(color: UIColor.darkGray, width: 1)
        containerView.border(color: UIColor.darkGray, width: 1)
        childContainerView.border(color: UIColor.darkGray, width: 1)

        
        self.topView.addSubview(mydatePicker)
        self.mydatePicker.bounds = topView.bounds
        self.mydatePicker.center = topView.center
        mydatePicker.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        mydatePicker.widthAnchor.constraint(equalTo: topView.widthAnchor).isActive = true
        mydatePicker.heightAnchor.constraint(equalTo: topView.heightAnchor).isActive = true
        mydatePicker.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        mydatePicker.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true

    }
    
    
    @IBAction func setUpGoalBtnPressed(_ sender: Any) {
        presentGoalsVc()
    }
    
    

    func presentGoalsVc() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SetUpYourGoalController") as? SetUpYourGoalController, let pet = self.pet {
            vc.petUser = pet.owner
            vc.isOwner = pet.isOwner
            vc.pet = pet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Adventure")
    }
}


class AdvenetureeHistroyCell: UITableViewCell {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var adventureImage: UIImageView!
    @IBOutlet weak var petName: UILabel!
}
