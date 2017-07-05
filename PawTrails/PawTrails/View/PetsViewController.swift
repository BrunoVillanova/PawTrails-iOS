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
    
    var refreshControl = UIRefreshControl()
    
    fileprivate let presenter = PetsPresenter()
    
    fileprivate var pets = [Int:IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noPetsFound.isHidden = true

        tableView.tableFooterView = UIView()
        
        refreshControl.backgroundColor = UIColor.secondaryColor()
        refreshControl.tintColor = UIColor.primaryColor()
        refreshControl.addTarget(self, action: #selector(reloadPetsAPI), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        UIApplication.shared.statusBarStyle = .lightContent
        presenter.attachView(self)
    }
    
    @objc func reloadPetsAPI(){
        presenter.loadPets()
    }
    
    deinit {
        presenter.deteachView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadPets()
        presenter.startPetsListUpdates()
        presenter.startPetsGPSUpdates { (id) in
            self.updateRow(by: id)
        }
        presenter.startPetsGeocodeUpdates { (geocode) in
            self.updateRow(by: geocode.id)
        }
    }
    
    private func updateRow(by id: Int){
        
        Reporter.debugPrint(file: "#file", function: "#function", "Update Pet \(id)")
        if let index = self.pets[id] {
            self.tableView.reloadRows(at: [index], with: .automatic)
        }else{
            self.errorMessage(ErrorMsg.init(title: "", msg: "WTF"))
        }
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
        pets[pet.id] = indexPath
        cell.batteryImageView.circle()
        cell.signalImageView.circle()
        
        if let data = SocketIOManager.instance.getGPSData(for: pet.id) {
            cell.batteryImageView.backgroundColor = UIColor.primaryColor()
            cell.signalImageView.backgroundColor = UIColor.primaryColor()
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

        if let home = tabBarController?.viewControllers?.first as? HomeViewController {
            home.selectedPet = presenter.getPet(with: sender.tag)
            tabBarController?.selectedIndex = 0
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is PetProfileTableViewController {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! PetProfileTableViewController).pet = getPet(at: indexPath)
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
}
