//
//  MapViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 04/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import GSMessages

class MapViewController: PTViewController {
    
    @IBOutlet weak var mapView: PTMapView!
    @IBOutlet weak var firstButtonfromthebottom: UIButton!
    @IBOutlet weak var secButtonFromTheBottom: UIButton!
    @IBOutlet weak var thirdButtonFromTheBottom: UIButton!
    @IBOutlet weak var refreshBarBtn: UIBarButtonItem!
    
    fileprivate let presenter = HomePresenter()
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    fileprivate let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    fileprivate let refreshIconImage = UIImage(named: "RefreshButtonIcon")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    
    var selectedPet: Pet?
    var data = [searchElement]()
    var activeTrips = [Trip]()
    var isDisplayedPetScreen = false
    fileprivate var isFirstTimeViewAppears = true

    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.showGpsUpdates()
        
        if isDisplayedPetScreen {
            reloadPets()
            isDisplayedPetScreen = false;
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstTimeViewAppears {
            isFirstTimeViewAppears = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectPetsViewController = segue.destination as? SelectPetsVC {
            selectPetsViewController.action = selectPetsAction.startAdventure
        }
    }
    
    
    fileprivate func initialize() {
        SocketIOManager.instance.connect()
        mapView.calloutDelegate = self
        DataManager.instance.getActivePetTrips()
            .subscribe(onNext: { (tripList) in
                self.activeTrips = tripList
                self.firstButtonfromthebottom.isEnabled = true
                Reporter.debugPrint("MapViewController -> getActivePetTrips \(tripList.count)")
                if (tripList.count > 0){
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
                    gestureRecognizer.delegate = self
                    if !isBetaDemo {
                        self.alertwithGeature(title: "", msg: "ADVENTURE IN PROGRESS, CLICK TO RESUME", type: .red, disableTime: 150, geatureReconginzer: gestureRecognizer, handler: nil)
                    }
                } else {
                    Reporter.debugPrint("No running trips")
                    self.hideNotification()
                }

            }).disposed(by: disposeBag)
        
        
        DataManager.instance.allPetDeviceData(.live).subscribe(onNext: { (petDeviceDataList) in
            Reporter.debugPrint("MapViewController -> allPetDeviceData \(petDeviceDataList.count)")
            
            if (petDeviceDataList.count > 0) {
               self.hideMessage()
            }
        }).disposed(by: disposeBag)
        
        firstButtonfromthebottom.isEnabled = false
        
        presenter.attachView(self)
        reloadPets()
        
        UIApplication.shared.statusBarStyle = .default
        button.addTarget(self, action:  #selector(self.refreshBtnPressed(_:)), for: .touchUpInside)
        button.setImage(refreshIconImage, for: .normal)
        button.tintColor = PTConstants.colors.darkGray
        self.navigationItem.rightBarButtonItem?.customView = button
        self.navigationItem.rightBarButtonItem?.tintColor = PTConstants.colors.primary
        
        
        let notificationIdentifier: String = "petAdded"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPets), name: NSNotification.Name(rawValue: notificationIdentifier), object: nil)
        
        DataManager.instance.pets().subscribe(onNext: { (pets) in
            if pets.isEmpty || pets.count == 0 {
                self.appDelegate.showPetWizardModally(true)
            }
            
        }).disposed(by: disposeBag)
        
        configureNavigationBar()
    }
    
    fileprivate func configureNavigationBar() {
        if let navigationController = self.navigationController as? PTNavigationViewController {
            navigationController.showNavigationBarDropShadow = true
        }
    }

    func reloadPets(){
        presenter.getPets()
    }
    
    deinit {
        self.presenter.deteachView()
    }
    
    
    // HomeView --
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    
    fileprivate func showIndicator() {
        refreshBarBtn.customView = self.activityIndicator
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        refreshBarBtn.isEnabled = false
    }
    
    fileprivate func hideIndicator() {
        refreshBarBtn.isEnabled = true
        activityIndicator.stopAnimating()
        button.setImage(refreshIconImage, for: .normal)
        navigationItem.rightBarButtonItem?.customView = button
    }
    
    @IBAction func refreshBtnPressed(_ sender: Any) {
        if presenter.pets.count != 0 {
            let petIDs = presenter.pets.map { $0.id  }
            showIndicator()
            
            self.showMessage("Searching for new location...", type: GSMessageType.info,  options: [
                .animation(.slide),
                .animationDuration(0.3),
                .autoHide(false),
                .cornerRadius(0.0),
                .hideOnTap(false),
                .position(.top),
                .height(36.0),
                .textAlignment(.center),
                .textNumberOfLines(1),
                ])
            
            APIRepository.instance.getImmediateLocation(petIDs) { (error) in
                self.hideIndicator()
                if let error = error {
                    Reporter.debugPrint(error.localizedDescription)
                } else {
                    self.mapView.showGpsUpdates()
                }
            }
        } else {
            self.showMessage("Please add a pet first", type: GSMessageType.info,  options: [
                .animation(.slide),
                .animationDuration(0.3),
                .autoHide(false),
                .cornerRadius(0.0),
                .height(36.0),
                .hideOnTap(false),
                .position(.top),
                .textAlignment(.center),
                .textNumberOfLines(1),
                ])
        }
    }
    
    @IBAction func firstButtonPressed(_ sender: Any) {
        if self.activeTrips.isEmpty {
            if let nc = self.storyboard?.instantiateViewController(withIdentifier: "selectPetsNavigation") as? UINavigationController,
                let selectPetsViewController = nc.topViewController as? SelectPetsVC {
                selectPetsViewController.action = selectPetsAction.startAdventure
                self.navigationController?.present(nc, animated: true, completion: nil)
            }
        } else {
            performSegue(withIdentifier: "adventrueInProgress", sender: nil)
        }
    }
    
    @IBAction func secButtonPressed(_ sender: Any) {
        showSelectPetAlert("Select Pet to Focus", selectedAction: {alert, selectedPet in
            alert.dismiss(animated: true)
            self.mapView.focusOnPet(selectedPet)
        })
    }
    
    @IBAction func thirdButtonPressed(_ sender: Any) {
        mapView.showAnnotations([self.mapView.userLocation], animated: true)
    }
    
    
    func presentPet(_ pet: Pet, activityEnabled:Bool = false) {
        
        let nc = UINavigationController()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PetProfileCollectionViewController") as? PetInfromationViewController {
            vc.pet = pet
            nc.pushViewController(vc, animated: true)
            present(nc, animated: true, completion: nil)
        }
    }
    
    fileprivate func goToPetDetails(_ pet: Pet) {
        if let petDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetDetails") as? TabPageViewController {
            petDetailsViewController.pet = pet
            self.navigationController?.pushViewController(petDetailsViewController, animated: true)
        }
    }
    
//    fileprivate func showSelectPetAlert() {
//        let title = "Select Pet to Focus"
//
//        let alertView = PTAlertViewController(title, buttonTypes: nil, titleBarStyle: .green)
//
//        //// TableView setup
//        let contentX:CGFloat = 24
//        let contentY:CGFloat = 16
//        let contentHeight:CGFloat = 46
//        let rowHeight:CGFloat = 82
//        let minTableViewSize:CGFloat = 1*rowHeight
//        let maxTableViewSize:CGFloat = 3*rowHeight
//        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: minTableViewSize), style: .plain)
//        let cellIdentifier = "cell"
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
//        tableView.rowHeight = rowHeight
//        tableView.separatorStyle = .none
//
//        let pets = DataManager.instance.pets()
//
//        pets
//            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier,
//                                         cellType: UITableViewCell.self)) {row, element, cell in
//
//                                            let _ = cell.contentView.subviews.map { $0.removeFromSuperview() }
//
//                                            cell.selectionStyle = .none
//
//                                            // Main View
//                                            let mainView = PTCircleImageTitleView(frame:  CGRect(x: contentX, y: contentY, width: cell.contentView.bounds.width, height: contentHeight))
//
//                                            if let petImageURLString = element.imageURL {
//                                                mainView.imageView.sd_setImage(with: URL(string: petImageURLString), completed: nil)
//                                            }
//
//                                            mainView.titleLabel.text = element.name
//                                            cell.contentView.addSubview(mainView)
//
//                                            // Separator
//                                            let separatorView = UIView(frame: CGRect(x: 0, y: cell.contentView.bounds.height-1, width: cell.contentView.bounds.width, height: 1))
//                                            separatorView.backgroundColor = PTConstants.colors.newLightGray
//                                            separatorView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//                                            cell.contentView.addSubview(separatorView)
//            }
//            .disposed(by: disposeBag)
//
//        tableView.rx.modelSelected(Pet.self)
//            .asObservable()
//            .subscribe(onNext: { (pet) in
//                alertView.dismiss(animated: true)
//                self.mapView.focusOnPet(pet)
//            })
//            .disposed(by: disposeBag)
//
//
//        alertView.contentView.addSubview(tableView)
//        alertView.alertWillAppear = {alert in
//            let bottomOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height)
//            tableView.setContentOffset(bottomOffset, animated: false)
//        }
//
//        // Footer View
//        let footerViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: rowHeight))
//        let footerView = PTCircleImageTitleView(frame:  CGRect(x: contentX, y: contentY, width: footerViewContainer.bounds.size.width-contentX, height: contentHeight))
//        footerView.imageView.image = UIImage(named: "CirclePlusIcon")
//        footerView.titleLabel.text = "Add Pet"
//        footerViewContainer.addTapGestureRecognizer {
//            alertView.dismiss(animated: true, completion: {
//                self.appDelegate.presentViewController(ViewController.petWizard)
//            })
//        }
//        footerViewContainer.addSubview(footerView)
//        tableView.tableFooterView = footerViewContainer
//
//        pets
//            .subscribe(onNext: { (pets) in
//                let newSize = minTableViewSize + CGFloat(pets.count)*rowHeight
//                let theHeight = newSize < maxTableViewSize ? newSize : maxTableViewSize
//
//                alertView.setContentViewHeightAnimated(theHeight, afterHeightChanged: {
//                    let bottomOffset = CGPoint(x: 0, y: 0)
//                    tableView.setContentOffset(bottomOffset, animated: false)
//                })
//            })
//            .disposed(by: disposeBag)
//
//        // Present
//        self.present(alertView, animated: true, completion: nil)
//    }
//
}

class PTCircleImageTitleView: UIView {
    
    let imageView = UIImageView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    fileprivate func setupView() {
        // Image View
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(46)
            make.width.equalTo(46)
        }
        
        // Title Label
        titleLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
        titleLabel.textColor = PTConstants.colors.darkGray
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(24)
            make.right.equalToSuperview()
            make.centerY.equalTo(imageView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.circle()
    }
}

//MARK: HomeView
extension MapViewController: HomeView {
    func success() {
    
    }
    
    func loadPets(){

    }
    
    func reload() {
        
    }
    
    func userNotSigned() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        if let vc = loginStoryboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            let navController = UINavigationController(rootViewController: vc)
            self.present(navController, animated: true, completion: {
                self.tabBarController?.selectedIndex = 0
            })
        }
    }
    
    func noPetsFound() {
        alert(title: "", msg: "No pets found", type: .blue)
    }
}

//MARK: GestureRecognizer Delegate
extension MapViewController: UIGestureRecognizerDelegate {
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        self.performSegue(withIdentifier: "adventrueInProgress", sender: nil)
//        self.hideNotification()
    }
}


//MARK: -
//MARK: MapView Delegate
extension MapViewController: PTPetCalloutViewDelegate {
    
    func didTapOnCallout(annotation: PTAnnotation) {
        
        if let petDeviceData = annotation.petDeviceData {
             isDisplayedPetScreen = true
             self.goToPetDetails(petDeviceData.pet)
        }
    }
}
