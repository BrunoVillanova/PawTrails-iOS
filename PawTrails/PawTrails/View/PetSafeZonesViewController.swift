//
//  PetSafeZonesViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 03/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetSafeZonesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noElementsLabel: UILabel!

    var pet:Pet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Safe Zones Edit"
        navigationItem.prompt = pet.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(PetSafeZonesViewController.addSafeZone))
        noElementsLabel.isHidden = (pet.safezones != nil && pet.safezones!.count > 0)
        tableView.tableFooterView = UIView()
    }
    
    func addSafeZone() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddAddEditSafeZoneViewController") {
//            present(vc, animated: true, completion: nil)
//            navigationController?.present(vc, animated: true, completion: nil)
            tabBarController?.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pet.safezones?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! safeZoneTableViewCell
        if let safeZone = pet.safezones?.allObjects[indexPath.row] as? SafeZone {
            cell.nameLabel.text = safeZone.name
            if let preview = safeZone.preview {
                cell.mapImageView.image = UIImage(data: preview as Data)
            }else{
                cell.mapImageView.backgroundColor = UIColor.random()
            }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class safeZoneTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
}
