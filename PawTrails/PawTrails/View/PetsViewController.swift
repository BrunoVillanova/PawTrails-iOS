//
//  PetsViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 31/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PetsView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPetsFound: UILabel!
    
    fileprivate let presenter = PetsPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        presenter.attachView(self)
        noPetsFound.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    deinit {
        presenter.deteachView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
//        presenter.loadPets()
        presenter.startPetsListUpdates()
        presenter.startPetsGPSUpdates { (id, update) in
            if update {
                self.updateRow(by: id)
            }
        }
        presenter.startPetsGeocodeUpdates { (geocode) in
            if let geocode = geocode {
                self.updateRow(by: geocode.petId)
            }
        }
    }
    
    private func updateRow(by id: Int16){
        DispatchQueue.main.async {
            debugPrint("Update Pet \(id)")
            if let index = self.presenter.ownedPets.index(where: { $0.id == id }) {
                self.tableView.reloadRows(at: [IndexPath.init(item: index, section: 0)], with: .automatic)
            }else if let index = self.presenter.sharedPets.index(where: { $0.id == id }) {
                self.tableView.reloadRows(at: [IndexPath.init(item: index, section: 1)], with: .automatic)
            }else{
                self.errorMessage(ErrorMsg.init(title: "", msg: "WTF"))
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.stopPetListUpdates()
        presenter.stopPetGPSUpdates()
        presenter.stopPetsGeocodeUpdates()
    }


    // MARK: - PetsView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func loadPets() {
        noPetsFound.isHidden = presenter.sharedPets.count != 0 || presenter.ownedPets.count != 0
//        for pet in presenter.ownedPets {
//            SocketIOManager.Instance.startPetGPSUpdates(for: pet.id)
//        }
//        for pet in presenter.sharedPets {
//            SocketIOManager.Instance.startPetGPSUpdates(for: pet.id)
//        }
        tableView.reloadData()
    }
    
    func petsNotFound() {
        tableView.reloadData()
        noPetsFound.isHidden = false
    }
        
    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        var number = 0
        if presenter.ownedPets.count != 0 { number += 1 }
        if presenter.sharedPets.count != 0 { number += 1 }
        return number
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? presenter.ownedPets.count : presenter.sharedPets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! petListCell
        let pet = indexPath.section == 0 ? presenter.ownedPets[indexPath.row] : presenter.sharedPets[indexPath.row]
        cell.batteryImageView.circle()
        cell.signalImageView.circle()
        
        if let data = SocketIOManager.Instance.getPetGPSData(id: pet.id) {
            cell.batteryImageView.backgroundColor = UIColor.orange()
            cell.signalImageView.backgroundColor = UIColor.orange()
            cell.batteryLabel.text = data.batteryString
            cell.batteryLabel.textColor = UIColor.darkText
            cell.signalLabel.text = data.signalString
            cell.signalLabel.textColor = UIColor.darkText
            if data.locationAndTime != "" {
                cell.subtitleLabel.text = data.locationAndTime
                cell.subtitleLabel.textColor = UIColor.darkText
            }else{
                cell.subtitleLabel.text = cell.subtitleLabel.text
                cell.subtitleLabel.textColor = UIColor.lightText
            }
        }else{
            cell.batteryImageView.backgroundColor = UIColor.clear
            cell.signalImageView.backgroundColor = UIColor.clear
            cell.batteryLabel.text = cell.batteryLabel.text
            cell.batteryLabel.textColor = UIColor.lightText
            cell.signalLabel.text = cell.signalLabel.text
            cell.signalLabel.textColor = UIColor.lightText
            cell.subtitleLabel.text = cell.subtitleLabel.text
            cell.subtitleLabel.textColor = UIColor.lightText
        }
        
        cell.titleLabel.text = pet.name
        if let imageData = pet.image as Data? {
            cell.petImageView.image = UIImage(data: imageData)
        }else{
            cell.petImageView.image = nil
        }
        cell.petImageView.circle()
//        cell.trackButton.round()
        cell.trackButton.isHidden = true
//        cell.trackButton.addTarget(self, action: #selector(PetsViewController.trackButtonAction(sender:)), for: .touchUpInside)
//        cell.trackButton.tag = Int(pet.id)
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

    func trackButtonAction(sender: UIButton){

        if let home = tabBarController?.viewControllers?.first as? HomeViewController {
            home.selectedPet = presenter.getPet(with: sender.tag)
            tabBarController?.selectedIndex = 0
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is PetsPageViewController {
            
            if let index = tableView.indexPathForSelectedRow {
                (segue.destination as! PetsPageViewController).pet = index.section == 0 ? presenter.ownedPets[index.row] : presenter.sharedPets[index.row]
            }
        }
    }
}

class petListCell: UITableViewCell {
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signalImageView: UIImageView!
    @IBOutlet weak var batteryImageView: UIImageView!
    @IBOutlet weak var signalLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var trackButton: UIButton!
}
