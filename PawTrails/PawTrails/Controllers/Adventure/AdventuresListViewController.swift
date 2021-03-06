//
//  AdventuresListViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 07/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import RxSwift
import RxCocoa
import SCLAlertView
import GSMessages
import SnapKit

class AdventuresListViewController: UIViewController  {
    
    var pet: Pet!
    @IBOutlet weak var achievementsView: AdventuresAchievementsView!
    @IBOutlet weak var tableView: UITableView!

    var startDate: Int?
    var startDateInDateFormate: Date?
    var endDate: Int?
    let disposeBag = DisposeBag()
    var currentTripsPage: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showGoalsDate()
    }
    
    fileprivate func initialize() {
        tableView.tableFooterView = UIView()

        retrieveTrips()
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Trip.self))
            .bind { [unowned self] indexPath, item in
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.goToTripDetailsIfNeeded(item)
            }
            .disposed(by: disposeBag)
    }
    
    fileprivate func retrieveTrips() {
    
        DataManager.instance.getTrips([2], from: startDate, to: endDate, page: currentTripsPage)
            .map({ [unowned self] (trips) -> [Trip] in
                return trips.filter({ (trip) -> Bool in
                    return trip.pet.id == self.pet.id
                })
            })
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: AdventureHistoryCell.self)) { (_, element, cell) in
                cell.selectionStyle = .none
                cell.configure(element)
                cell.delegate = self
                
            }.disposed(by: disposeBag)
    }
    
    fileprivate func goToTripDetailsIfNeeded(_ trip: Trip) {
        
        if trip.hasLocationData {
            let tripDetailViewController = TripDetailViewController()
            tripDetailViewController.trips = [trip]
            
            self.navigationController?.pushViewController(tripDetailViewController, animated: true)
        }
    }
    
    fileprivate func showGoalsDate() {
        let mydatePicker = achievementsView.mydatePicker
        mydatePicker.delegate = self
        if let date = mydatePicker.selectedStartDate {
            startDate = Int(date.timeIntervalSince1970)
            startDateInDateFormate = date
        } else {
            let date = Date()
            let gregorian = Calendar(identifier: .gregorian)
            var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            components.hour = 0
            components.minute = 0
            components.second = 0
            guard let newDate = gregorian.date(from: components) else {return}
            startDate = Int(newDate.timeIntervalSince1970)
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
        
        if isBetaDemo {
            
            startDate = 1520476061
        }
        
        if let startDate = self.startDate, let endDate = self.endDate {
            APIRepository.instance.getPetTripAchievements(self.pet.id, from: startDate, to: endDate, status: [2]) { (error, achievements) in
                if error == nil, let achievements = achievements {
                    self.achievementsView.configure(achievements)
                } else if let error = error {
                    Reporter.debugPrint(error.localizedDescription)
                }
            }
            retrieveTrips()
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
    
    
    fileprivate func presentGoalsVc() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SetUpYourGoalController") as? SetUpYourGoalController, let pet = self.pet {
            vc.petUser = pet.owner
            vc.isOwner = pet.isOwner
            vc.pet = pet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension AdventuresListViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Adventure")
    }
}

extension AdventuresListViewController: AdventureHistoryCellDelegate {
    func delete(cell: UITableViewCell, trip: Trip) {
        
        let title: String = "Delete adventure?"
        let subTitle: String = "Cannot undo this action."
        let buttonOkTitle: String = "Delete adventure!"
        let buttonCancelTitle: String = "No, keep this."
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: true
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton(buttonOkTitle) {
            APIRepository.instance.deleteTrips([Int(trip.id)]) { error in
                if let error = error {
                    Reporter.debugPrint("\(error.localizedDescription)")
                    
                    var errorMessage = "Error deleting adventure"
                    
                    if let errorCode = error.errorCode {
                        errorMessage = errorMessage + "\n\n" + errorCode.description
                    }
                    
                    self.showMessage(errorMessage,
                                     type: .error,
                                     options: [.animation(.slide),
                                               .animationDuration(0.3),
                                               .autoHide(true),
                                               .cornerRadius(0.0),
                                                .hideOnTap(true),
                                                .position(.top),
                                                .textAlignment(.center),
                                                .textNumberOfLines(0),
                                        ])
                } else {
                    
                    self.retrieveTrips()
                    
                    self.showMessage("Adventure deleted!",
                                     type: .success,
                                     options: [.animation(.slide),
                                                .animationDuration(0.3),
                                                .autoHide(true),
                                                .cornerRadius(0.0),
                                                .hideOnTap(true),
                                                .position(.top),
                                                .textAlignment(.center),
                                                .textNumberOfLines(0),
                                                ])
                }
            }
        }
        
        alertView.addButton(buttonCancelTitle) {
            Reporter.debugPrint("User canceled action!")
        }
        
        
        alertView.showTitle(
            title,
            subTitle: subTitle,
            style: .warning,
            colorStyle: 0xD4143D,
            colorTextButton: 0xFFFFFF,
            circleIconImage: UIImage(named: "DeleteForeverIcon48")
        )
        

    }
}

protocol AdventureHistoryCellDelegate {
    func delete(cell: UITableViewCell, trip: Trip)
}

class AdventureHistoryCell: UITableViewCell {
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var adventureImage: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    var currentTrip: Trip?
    var delegate: AdventureHistoryCellDelegate?
    var mapView: PTMapView?
    var noDataView: UIView?
    
    override func layoutSubviews() {
        configureLayout()
    }
    
    override func prepareForReuse() {
        dateLbl.text = nil
        for view in adventureImage.subviews {
            view.removeFromSuperview()
        }
    }
    
    fileprivate func configureLayout() {
        if let view = mainView {
            view.layer.borderColor = PTConstants.colors.lightGray.cgColor
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 5
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowRadius = 4.0
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = CGSize.zero
            view.layer.masksToBounds = true
        }
    }
    
    func configure(_ trip: Trip) {
        
        self.currentTrip = trip
        
        deleteButton.isHidden = !trip.pet.isOwner
        
        if let ts = trip.startTimestamp {
            let tripStartTimestamp = Double(ts)
            let date = Date(timeIntervalSince1970: tripStartTimestamp)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatter.locale = NSLocale.current
            dateFormatter.amSymbol = "am"
            dateFormatter.pmSymbol = "pm"
            dateFormatter.dateFormat = "h:mma, d MMM, yyyy"
            let strDate = dateFormatter.string(from: date)
            dateLbl.text = strDate
        }
        
        if trip.hasLocationData {
            
            if mapView == nil {
                mapView = PTMapView()
                mapView?.isStaticView = true
            }
            
            mapView?.setStaticTripView(trip)
            adventureImage.addSubview(mapView!)
            
            mapView?.snp.makeConstraints({ (maker) in
                maker.edges.equalToSuperview()
            })
            
        } else {
            
            if noDataView == nil {
                noDataView = UIView(frame: .zero)
                noDataView?.backgroundColor = PTConstants.colors.lightGray
                let noDataLabel = UILabel()
                noDataLabel.numberOfLines = 0
                noDataLabel.textAlignment = .center
                noDataLabel.textColor = UIColor(rgb: 0x666666)
                noDataLabel.font = UIFont(name: "Roboto-Medium", size:16)
                noDataLabel.text = "=(\nThere are no location points in this adventure!\nMaybe did not record for too long or did not have internet connection"
                noDataView?.addSubview(noDataLabel)
                
                noDataLabel.snp.makeConstraints({ (maker) in
                    maker.centerX.equalToSuperview()
                    maker.centerY.equalToSuperview()
                    maker.leading.greaterThanOrEqualToSuperview().offset(16)
                    maker.trailing.greaterThanOrEqualToSuperview().offset(16)
                })
            }
            
            adventureImage.addSubview(noDataView!)
            
            noDataView?.snp.makeConstraints({ (maker) in
                maker.edges.equalToSuperview()
            })
        }
    }
    
    @IBAction func deleteAdventureTapped(_ sender: Any) {
        if let trip = self.currentTrip {
            delegate?.delete(cell: self, trip: trip)
        }
    }
}


class AdventuresAchievementsView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var distanceCircle: CircleChart!
    @IBOutlet weak var timeCircle: CircleChart!
    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    lazy var mydatePicker: AirbnbDatePicker = {
        let btn = AirbnbDatePicker()
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func awakeFromNib() {
        initialize()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func initialize() {
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
        
        if isBetaDemo {
            mydatePicker.selectedStartDate = Date(timeIntervalSince1970: 1520473967) // March 8
            mydatePicker.selectedEndDate = Date() // Current date
            mydatePicker.dateInputButton.setTitle("\(mydatePicker.dateFormatter.string(from: mydatePicker.selectedStartDate!)) - \(mydatePicker.dateFormatter.string(from: mydatePicker.selectedEndDate!))", for: .normal)
        }
    }
    
    func configure(_ tripAchievements: TripAchievements) {
        var distanceAchievement = CGFloat()
        var timeGoalAchievmenet = CGFloat()
        let distanceColor = UIColor(red: 153/255, green: 202/255, blue: 186/255, alpha: 1)
        let timeColor = UIColor(red: 211/255, green: 100/255, blue: 59/255, alpha: 1)
        let distanceGoalForPeriod = tripAchievements.distance * tripAchievements.totalDays
        let timeGoalForPeriod = tripAchievements.timeGoal * tripAchievements.totalDays
        let totalDistanceAchievement = tripAchievements.totalDistance / 1000
        let totalHour = tripAchievements.totalTime / 60
        
        if timeGoalForPeriod > 0 {
            timeGoalAchievmenet = CGFloat((100 * tripAchievements.totalTime) / timeGoalForPeriod)
            
        } else {
            timeGoalAchievmenet = 0
        }
        
        if distanceGoalForPeriod > 0 {
            distanceAchievement = CGFloat((100 * tripAchievements.totalDistance) / distanceGoalForPeriod)
            
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
    }
}
