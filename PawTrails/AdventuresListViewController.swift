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
    
    var startDate: Int?
    var startDateInDateFormate: Date?
    var endDate: Int?

    
    lazy var mydatePicker: AirbnbDatePicker = {
        let btn = AirbnbDatePicker()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.delegate = self
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
    
    
    override func viewWillAppear(_ animated: Bool) {
      showGoalsDate()
    }
    
    
    func showGoalsDate() {
        if let date = mydatePicker.selectedStartDate {
            startDate = Int(date.timeIntervalSince1970)
            startDateInDateFormate = date
        } else {
            let date = Date()
            startDate = Int(date.timeIntervalSince1970)
            startDateInDateFormate = date
        }
        
        if let date = mydatePicker.selectedEndDate, date != mydatePicker.selectedStartDate {
            endDate = Int(date.timeIntervalSince1970)
            
        } else if mydatePicker.selectedStartDate == mydatePicker.selectedEndDate {
            if let startDate = self.startDateInDateFormate, let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startDate) {
                endDate = Int(tomorrow.timeIntervalSince1970)
            }
        } else if let startDate = self.startDateInDateFormate ,let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
            
        {
            endDate = Int(tomorrow.timeIntervalSince1970)
        }
        
        
        if let startDate = self.startDate, let endDate = self.endDate {
            APIRepository.instance.getPetTripAchievements(self.pet.id, from: startDate, to: endDate, status: [2]) { (error, achievments) in
                if error == nil, let achieve = achievments {
                    var distanceAchievement = CGFloat()
                    var timeGoalAchievmenet = CGFloat()
                    
                    
                    let distanceColor = UIColor(red: 153/255, green: 202/255, blue: 186/255, alpha: 1)
                    let timeColor = UIColor(red: 211/255, green: 100/255, blue: 59/255, alpha: 1)
                    
                    let distanceGoalForPeriod = achieve.distance * achieve.totalDays
                    
                    let timeGoalForPeriod = achieve.timeGoal * achieve.totalDays
                    
                    let totalDistanceAchievement = achieve.totalDistance / 1000
                    let totalHour = achieve.totalTime / 60
                    if timeGoalForPeriod > 0 {
                        timeGoalAchievmenet = CGFloat((100 * achieve.totalTime) / timeGoalForPeriod)
                        print(timeGoalAchievmenet)
                    } else {
                        timeGoalAchievmenet = 0
                    }
                    
                    if distanceGoalForPeriod > 0 {
                        distanceAchievement = CGFloat((100 * achieve.totalDistance) / distanceGoalForPeriod)
                        
                    } else {
                        distanceAchievement = 0
                    }
                    if distanceAchievement > 1 {
                        self.distanceCircle.setChart(at: 1, color: distanceColor, text: "\(totalDistanceAchievement) km")
                    } else {
                        self.distanceCircle.setChart(at: distanceAchievement, color: distanceColor, text: "\(totalDistanceAchievement) km")
                    }
                    if timeGoalAchievmenet > 1 {
                        self.timeCircle.setChart(at: 1, color: timeColor, text:  "\(totalHour) hrs")
                    } else {
                        self.timeCircle.setChart(at: timeGoalAchievmenet, color: timeColor, text:  "\(totalHour) hrs")
                    }
                    
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        
        
    }
    
   
    
    
    
    @IBAction func setUpGoalBtnPressed(_ sender: Any) {
        guard let pet = self.pet else {return}
        guard let petName = pet.name else {return}
        if !pet.isOwner {
            self.alert(title: "", msg: "Only \(petName) owner can edit trip goal. ", type: .blue, disableTime: 5, handler: nil)
        } else {
            presentGoalsVc()
        }

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
