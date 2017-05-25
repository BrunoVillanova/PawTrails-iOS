//
//  PetSafeZonesViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 03/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit

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
        present()
    }
    
    func present(safezone: SafeZone? = nil){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditSafeZoneViewController") as? AddEditSafeZoneViewController {
            vc.safezone = safezone
            vc.petId = pet.id
            vc.isOwner = pet.isOwner
            tabBarController?.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pet.sortedSafeZones?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! safeZoneTableViewCell
        if let safezone = pet.sortedSafeZones?[indexPath.row] {
            cell.nameLabel.text = safezone.name
            cell.activeSwitch.isOn = safezone.active
            if let preview = safezone.preview {
                cell.mapImageView.image = UIImage(data: preview as Data)
            }else{
                if safezone.preview == nil, let center = safezone.point1?.coordinates, let topCenter = safezone.point2?.coordinates, let shape = Shape(rawValue: safezone.shape) {
                    MKMapView.getSnapShot(with: center, topCenter: topCenter, shape: shape, into: view, handler: { (image) in
                        cell.mapImageView.image = image
                    })
                }
            }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let safeZone = pet.sortedSafeZones?[indexPath.row] {
            present(safezone: safeZone)
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}

class safeZoneTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var activeSwitch: UISwitch!
}
