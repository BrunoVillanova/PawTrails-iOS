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
        
        navigationItem.leftBarButtonItem = presenter.pets.count > 0 ? editButtonItem : nil
        navigationItem.leftBarButtonItem?.action = #selector(PetsViewController.editAction(_:))
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    deinit {
        presenter.deteachView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        noPetsFound.isHidden = true
        presenter.loadPets()
    }
    
    func editAction(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.4) {
            self.editButtonItem.title = self.tableView.isEditing ? "Edit" : "Done"
            self.editButtonItem.style = self.tableView.isEditing ? .plain : .done
            self.tableView.isEditing = !self.tableView.isEditing
        }
    }
    

    // MARK: - PetsView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func loadPets() {
        tableView.reloadData()
    }
    
    func petsNotFound() {
        navigationItem.leftBarButtonItem = nil
        noPetsFound.isHidden = false
    }
    
    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.pets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! petListCell
        cell.titleLabel.text = presenter.pets[indexPath.row].name
        if let imageData = presenter.pets[indexPath.row].image as Data? {
            cell.petImageView.image = UIImage(data: imageData)
        }else{
            cell.petImageView.image = nil
        }
        cell.subtitleLabel.text = presenter.pets[indexPath.row].breeds
        cell.petImageView.circle()
        cell.trackButton.circle()
        cell.trackButton.addTarget(self, action: #selector(PetsViewController.trackButtonAction(sender:)), for: .touchUpInside)
        cell.trackButton.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let petName = presenter.pets[indexPath.row].name ?? ""
            
            popUpDestructive(title: "Remove \(petName)", msg: "If you proceed you will loose all the information of this pet.", cancelHandler: { (cancel) in
                tableView.reloadRows(at: [indexPath], with: .none)
            }, proceedHandler: { (remove) in
                if self.presenter.removePet(at: indexPath.row) {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }else{
                    self.alert(title: "", msg: "Couldn't remove the pet")
                }
            })
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func trackButtonAction(sender: UIButton){

        if let home = tabBarController?.viewControllers?.first as? HomeViewController {
            home.trackingPet = presenter.pets[sender.tag]
            tabBarController?.selectedIndex = 0
        }
        
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is PetsPageViewController {
            
            if let index = tableView.indexPathForSelectedRow {
                (segue.destination as! PetsPageViewController).pet = presenter.pets[index.row]
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
