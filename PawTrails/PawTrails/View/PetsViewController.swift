//
//  PetsViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 31/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift


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


        noPetsFound.isHidden = true

        tableView.tableFooterView = UIView()
        
        refreshControl.backgroundColor = UIColor.secondary
        refreshControl.tintColor = UIColor.primary
        refreshControl.addTarget(self, action: #selector(reloadPetsAPI), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        presenter.attachView(self)
        reloadPets()

        
        addButton()
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
    
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    @objc func reloadPetsAPI(){
        presenter.loadPets()
    }
    
    deinit {
        presenter.deteachView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.hideNotification()
    }
    
    

    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.stopPetListUpdates()
        presenter.stopPetGPSUpdates()
        presenter.stopPetsGeocodeUpdates()
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
        cell.subtitleLabel.text = "Getting address..."

        SocketIOManager.instance.gpsUpdates()?.subscribe(onNext: { (data) in
            if let json = data.first as? [Any] {
                for petDeviceDataObject in json {
                    if let petDeviceDataJson = petDeviceDataObject as? [String:Any] {
                        let petdata = PetDeviceData(petDeviceDataJson)
                        if petdata.pet.id == pet.id {
                            print(petdata.pet.id)
                            petdata.deviceData.coordinates.getFullFormatedAddress(handler: { (address) in
                                cell.subtitleLabel.text = address
                            })
                        }
                    }
                }
            } else{
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", data)
            }
        }){}.disposed(by: disposeBag)
        
        
        
        cell.titleLabel.text = pet.name
        if let imageData = pet.image as Data? {
            cell.petImageView.image = UIImage(data: imageData)
        }else{
            cell.petImageView.image = nil
        }
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
                if segue.destination is PetProfileCollectionViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
//                let info = PetInfromationCell()
//                info.pet = getPet(at: indexPath)
                (segue.destination as! PetProfileCollectionViewController).pet = getPet(at: indexPath)

            }
        }
    }
}

class petListCell: UITableViewCell {
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signalImageView: UIImageView!
    @IBOutlet weak var batteryImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    
  
}
