 //
//  PetsViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 31/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift
import SDWebImage
import RxCocoa


class PetsViewController: UIViewController, PetsView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPetsFound: UIView!
    @IBOutlet weak var addMyFirstPetButton: UIButton!
    
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate let presenter = PetsPresenter()
    fileprivate var pets = [Int:IndexPath]()
    fileprivate var petIdss = [Int]()
    fileprivate var petDeviceData: [PetDeviceData]?
    fileprivate let disposeBag = DisposeBag()
    fileprivate var iphoneX = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidLayoutSubviews() {
        
        if #available(iOS 11.0, *) {
            if ((UIApplication.shared.keyWindow?.safeAreaInsets.top)! > CGFloat(0.0)) {
                iphoneX = true
                Reporter.debugPrint("iphone x")
            } else {
                self.tabBarController?.tabBar.invalidateIntrinsicContentSize()
                self.tabBarController?.tabBar.isHidden = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TabPageViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! TabPageViewController).pet = getPet(at: indexPath)
            }
        }
    }
    
    @IBAction func addMyFirstPetButtonTapped(_ sender: Any) {
        self.goToAddDevice()
    }
    
    @IBAction func addDeviceButtonTapped(_ sender: Any) {
        self.goToAddDevice()
    }
    
    fileprivate func initialize() {
        
        noPetsFound.isHidden = true
        tableView.tableFooterView = UIView()
        
        refreshControl.backgroundColor = UIColor.secondary
        refreshControl.tintColor = UIColor.primary
        refreshControl.addTarget(self, action: #selector(reloadPetsAPI), for: .valueChanged)
        tableView.addSubview(refreshControl)
        presenter.attachView(self)
        reloadPets()
        
        tableView.dataSource = self
        tableView.delegate = self
        let notificationIdentifier: String = "petAdded"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPetsAPI), name: NSNotification.Name(rawValue: notificationIdentifier), object: nil)
        
        addMyFirstPetButton.backgroundColor = UIColor.primary
        addMyFirstPetButton.round()
        
//         Todo: make tableview reactive
//                DataManager.instance.pets()
//                    .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: petListCell.self)) { (_, element, cell) in
//                   cell.configure(element)
//                }.disposed(by: disposeBag)
        
    }
    
    
    fileprivate func addButton(){
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "StopTripButton-1x-png"), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        button.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -2).isActive = true
        if let tabbarhieght = self.tabBarController?.tabBar.frame.size.height {
            button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(tabbarhieght + 5)).isActive = true
        }
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    
    fileprivate func goToAddDevice() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "StepOneViewController") as? StepOneViewController {
            
            let navigationController = UINavigationController.init(rootViewController: vc)
            // Transparent navigation bar
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.isTranslucent = true
            navigationController.navigationBar.backgroundColor = UIColor.clear
            navigationController.navigationBar.tintColor = UIColor.white
            navigationController.navigationBar.topItem?.title = " "
            navigationController.navigationBar.backItem?.title = " "
            
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    
    @objc fileprivate func buttonAction(sender: UIButton!) {
        Reporter.debugPrint("Button tapped")
    }
    
    
    @objc func reloadPetsAPI(){
        presenter.loadPets()
        self.tableView.reloadData()
    }
    
    
    deinit {
        presenter.deteachView()
    }
    
    func reloadPets(){
        presenter.getPets()
    }

    // MARK: - PetsView
    
    func errorMessage(_ error: ErrorMsg) {
        refreshControl.endRefreshing()
        alert(title: error.title, msg: error.msg)
    }
    
    func loadPets() {
        refreshControl.endRefreshing()
        noPetsFound.isHidden = presenter.sharedPets.count != 0 || presenter.ownedPets.count != 0
        tableView.reloadData()
    }
    
    func petsNotFound() {
        refreshControl.endRefreshing()
        noPetsFound.isHidden = presenter.sharedPets.count != 0 || presenter.ownedPets.count != 0
        tableView.reloadData()
    }
    
    func getPet(at indexPath: IndexPath) -> Pet {
        if presenter.ownedPets.count > 0 && presenter.sharedPets.count > 0 {
            return indexPath.section == 0 ? presenter.ownedPets[indexPath.row] : presenter.sharedPets[indexPath.row]
        }else if presenter.ownedPets.count > 0 {
            return presenter.ownedPets[indexPath.row]
        }else{
            return presenter.sharedPets[indexPath.row]
        }
    }

    func trackButtonAction(sender: UIButton){
        // changed this when deleted homevc
        if let home = tabBarController?.viewControllers?.first as? MapViewController {
            home.selectedPet = presenter.getPet(with: sender.tag)
            tabBarController?.selectedIndex = 0
        }
    }
}
 
extension PetsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var number = 0
        if presenter.ownedPets.count != 0 { number += 1 }
        if presenter.sharedPets.count != 0 { number += 1 }
        return number
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if presenter.ownedPets.count > 0 && presenter.sharedPets.count > 0 {
            return section == 0 ? presenter.ownedPets.count : presenter.sharedPets.count
        }else{
            return presenter.ownedPets.count + presenter.sharedPets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! petListCell
        let pet = getPet(at: indexPath)
        cell.configure(pet)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if presenter.sharedPets.count != 0 && presenter.ownedPets.count != 0 {
            return section == 0 ? "Owned" : "Shared"
        }else if presenter.sharedPets.count != 0 {
            return "Shared"
        }else if presenter.ownedPets.count != 0 {
            return "Owned"
        }
        return nil
    }
}

 extension PetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
 }
 

class petListCell: UITableViewCell {
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signalLevels: NSLayoutConstraint!
    
    @IBOutlet weak var batteryLevel: PTBatteryView!
    @IBOutlet weak var subtitleLabel: UILabel!
    private let disposeBag = DisposeBag()
    
    func configure(_ pet: Pet) {
        titleLabel.text = pet.name
        
        if let imageUrl = pet.imageURL {
            petImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: #imageLiteral(resourceName: "PetPlaceholderImage"), options: [.continueInBackground])
        } else {
            petImageView.image = nil
        }
        
        subtitleLabel.text = "Bring your device outdoor to get location.."
        
        DataManager.instance.lastPetDeviceData(pet).subscribe(onNext: { (petDeviceData) in
            if let petDeviceData = petDeviceData {
                self.batteryLevel.setBatteryLevel(petDeviceData.deviceData.battery)
                petDeviceData.deviceData.point.getFullFormatedAddress(handler: { (address) in
                    self.subtitleLabel.text = address
                })
            }

        }).disposed(by: disposeBag)
    }
}
