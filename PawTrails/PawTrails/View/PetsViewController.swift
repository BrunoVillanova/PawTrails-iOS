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
        presenter.loadPets()
    }

    // MARK: - PetsView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func loadOwnedPets() {
        noPetsFound.isHidden = presenter.sharedPets.count != 0 || presenter.ownedPets.count != 0
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func loadSharedPets() {
        noPetsFound.isHidden = presenter.sharedPets.count != 0 || presenter.ownedPets.count != 0
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    func petsNotFound() {
        tableView.reloadData()
        noPetsFound.isHidden = false
    }
        
    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? presenter.ownedPets.count : presenter.sharedPets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! petListCell
        let pet = indexPath.section == 0 ? presenter.ownedPets[indexPath.row] : presenter.sharedPets[indexPath.row]
        cell.titleLabel.text = pet.name
        if let imageData = pet.image as Data? {
            cell.petImageView.image = UIImage(data: imageData)
        }else{
            cell.petImageView.image = nil
        }
        cell.subtitleLabel.text = pet.breeds
        cell.petImageView.circle()
        cell.trackButton.circle()
        cell.trackButton.addTarget(self, action: #selector(PetsViewController.trackButtonAction(sender:)), for: .touchUpInside)
        cell.trackButton.tag = Int(pet.id)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Owned" : "Shared"
    }

    func trackButtonAction(sender: UIButton){

        if let home = tabBarController?.viewControllers?.first as? HomeViewController {
            home.trackingPet = presenter.getPet(with: sender.tag)
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
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var trackButton: UIButton!
}
