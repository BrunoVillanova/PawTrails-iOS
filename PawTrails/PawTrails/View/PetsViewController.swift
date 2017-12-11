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
import BarcodeScanner

class PetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PetsView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPetsFound: UILabel!
    
    var refreshControl = UIRefreshControl()
    
    fileprivate let presenter = PetsPresenter()
    
    fileprivate var pets = [Int:IndexPath]()
    var petIdss = [Int]()
    private let disposeBag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
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
        
        
        // Todo: make tableview reactive
        //        DataManager.instance.pets()
        //            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: petListCell.self)) { (_, element, cell) in
        //           cell.configure(element)
        //        }.disposed(by: disposeBag)
        
        // Strings
        BarcodeScanner.Title.text = NSLocalizedString("Scan QR Code", comment: "")
        BarcodeScanner.CloseButton.text = NSLocalizedString("Close", comment: "")
        BarcodeScanner.SettingsButton.text = NSLocalizedString("Settings", comment: "")
        BarcodeScanner.Info.text = NSLocalizedString(
            "Place the QR code within the window to scan. The search will start automatically.", comment: "")
        BarcodeScanner.Info.loadingText = NSLocalizedString("Loading...", comment: "")
        BarcodeScanner.Info.notFoundText = NSLocalizedString("No product found.", comment: "")
        BarcodeScanner.Info.settingsText = NSLocalizedString(
            "To scan the QR Code you have to allow camera access under iOS settings.", comment: "")
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
    

    @IBAction func addDeviceButtonTapped(_ sender: Any) {
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    @objc func reloadPetsAPI(){
        presenter.loadPets()
        self.tableView.reloadData()
    }
    
    deinit {
        presenter.deteachView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.hideNotification()
        self.tabBarController?.tabBar.isHidden = false
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
    
    
    var petDeviceData: [PetDeviceData]?

    
        
    // MARK: - UITableViewDataSource

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
    
    func getPet(at indexPath: IndexPath) -> Pet {
        if presenter.ownedPets.count > 0 && presenter.sharedPets.count > 0 {
            return indexPath.section == 0 ? presenter.ownedPets[indexPath.row] : presenter.sharedPets[indexPath.row]
        }else if presenter.ownedPets.count > 0 {
            return presenter.ownedPets[indexPath.row]
        }else{
            return presenter.sharedPets[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! petListCell
        let pet = getPet(at: indexPath)
        cell.configure(pet)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

    func trackButtonAction(sender: UIButton){
        // changed this when deleted homevc
        if let home = tabBarController?.viewControllers?.first as? MapViewController {
            home.selectedPet = presenter.getPet(with: sender.tag)
            tabBarController?.selectedIndex = 0
        }
    }

    
//    // MARK: - Navigation
////
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.destination is TabPageViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! TabPageViewController).pet = getPet(at: indexPath)
            }
        }
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
        
        subtitleLabel.text = "Getting address ..."
        
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
 
extension PetsViewController: BarcodeScannerCodeDelegate {

    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {

        controller.dismiss(animated: true, completion: { [weak self] _ in
            if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "AddEditPetDetailsTableViewController") as? AddEditPetDetailsTableViewController {
                vc.deviceCode = code
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
}

 extension PetsViewController: BarcodeScannerErrorDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
 }
 
 extension PetsViewController: BarcodeScannerDismissalDelegate {
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
 }
