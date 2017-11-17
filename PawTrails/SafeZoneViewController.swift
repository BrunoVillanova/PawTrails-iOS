//
//  SafeZoneViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 02/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import MapKit


class SafeZoneViewController: UIViewController, IndicatorInfoProvider, PetView {
    var pet: Pet!
    fileprivate let presenter = PetPresenter()
    


    @IBAction func addButton(_ sender: Any) {
        if !pet.isOwner {
            self.alert(title: "", msg: "You cannot add user for this pet because you don't own it", type: .blue, disableTime: 5, handler: nil)
        } else {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditSafeZOneController") as? AddEditSafeZOneController {
                vc.petId = pet.id
                vc.isOwner = pet.isOwner
                navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAllData()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0)
        self.tableView.estimatedRowHeight = 450
        self.tableView.rowHeight = UITableViewAutomaticDimension
        presenter.attachView(self, pet:pet)
   
    }
    
    func loadAllData() {
        if let pet = pet {
            load(pet)
            reloadSafeZones()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            self.presenter.getPet(with: self.pet.id)
    }
    
    
    deinit {
        presenter.deteachView()
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "SafeZones")
    }
    
    
    func reloadPetInfo() {
        presenter.loadPet(with: pet.id)
    }
    
    func reloadSafeZones() {
        presenter.loadSafeZones(for: pet.id)
//        self.tableView.reloadData()
    }
    
    func reloadUsers(onlyDB: Bool = false) {

    }
    
    //MARK: - PetView
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func load(_ pet: Pet) {
        self.pet = pet
        navigationItem.title = pet.name
        self.tableView.reloadData()
        
    }
    
    func loadUsers() {

    }
    
    
    
  
    
    func loadSafeZones() {
        pet.safezones = presenter.safezones
        if self.presenter.safezones.count == 0 { return }
        let safezonesGroup = DispatchGroup()
        for safezone in self.presenter.safezones {
            // Address
            if safezone.address == nil {
                guard let center = safezone.point1 else {
                    Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "No center point found!")
                    break
                }
                GeocoderManager.Intance.reverse(type: .safezone, with: center, for: safezone.id)
            }
            // Map
            if safezone.preview == nil {
                guard let center = safezone.point1?.coordinates else {
                    Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "No center point found!")
                    continue
                }
                guard let topCenter = safezone.point2?.coordinates else {
                    Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "No topcenter point found!")
                    continue
                }
                
                safezonesGroup.enter()
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "map", safezone.id)
                self.buildMap(center: center, topCenter: topCenter, shape: safezone.shape, handler: { (image) in
                    if let image = image, let data = UIImagePNGRepresentation(image) {
                        Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "released", safezone.id)
                        self.presenter.set(imageData: data, for: safezone.id) { (errorMsg) in
                            if let errorMsg = errorMsg {
                                self.errorMessage(errorMsg)
                            }
                            safezonesGroup.leave()
                        }
                    }
                })
            }
        }
        
        safezonesGroup.notify(queue: .main, execute: {
            self.presenter.getPet(with: self.pet.id)
            
        })
    }
    
    func petNotFound() {
        alert(title: "", msg: "couldn't load pet")
    }
    
    
    func petRemoved() {
        if let petList = navigationController?.viewControllers.first(where: { $0 is PetsViewController}) as? PetsViewController {
            petList.reloadPets()
            navigationController?.popToViewController(petList, animated: true)
        }else{
            popAction(sender: nil)
        }
    }
    
    func removed() {
        
    }
    
    func buildMap(center: CLLocationCoordinate2D, topCenter: CLLocationCoordinate2D, shape: Shape, handler: @escaping ((UIImage?)->())){
        if CLLocationCoordinate2DIsValid(center) && CLLocationCoordinate2DIsValid(topCenter) {
            SnapshotMapManager.Intance.performSnapShot(with: center, topCenter: topCenter, shape: shape, handler: { (image) in
                handler(image)
            })
        }else{
            self.errorMessage(ErrorMsg.init(title: "", msg: "wrong coordinates"))
            handler(nil)
        }
    }
    func load(locationAndTime: String){
//        self.locationLabel.text = locationAndTime
    }
    
    func load(data: GPSData){
    }


}

extension SafeZoneViewController:UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.safezones.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SafeZoneCell
        let safezone = presenter.safezones[indexPath.row]
        cell.safeZoneName.text = safezone.name
        if safezone.image == 0 {
            cell.iconeImage.image = UIImage(named: Icons.zero.rawValue)
        } else if safezone.image == 1{
            cell.iconeImage.image = UIImage(named: Icons.one.rawValue)
        }else if safezone.image == 2 {
            cell.iconeImage.image = UIImage(named: Icons.two.rawValue)

        }else if safezone.image == 3 {
            cell.iconeImage.image = UIImage(named: Icons.three.rawValue)

        }else if safezone.image == 4 {
            cell.iconeImage.image = UIImage(named: Icons.four.rawValue)

        }else if safezone.image == 5{
            cell.iconeImage.image = UIImage(named: Icons.five.rawValue)
        }
        cell.safeZoneImage.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        cell.switcher.isOn = safezone.active
        cell.switcher.tag = indexPath.row
        cell.switcher.addTarget(self, action: #selector(changeSwitchAction(sender:)), for: UIControlEvents.valueChanged)
        if let preview = safezone.preview {
            cell.safeZoneImage.image = UIImage(data: preview as Data)
        }else{
            cell.safeZoneImage.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        present(presenter.safezones[indexPath.row])
    }
    
    func present(_ safezone: SafeZone?) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditSafeZOneController") as? AddEditSafeZOneController {
            vc.safezone = safezone
            vc.petId = pet.id
            vc.isOwner = pet.isOwner
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    

    
    func changeSwitchAction(sender: UISwitch){
        let safezone = presenter.safezones[sender.tag]
        presenter.setSafeZoneStatus(id: safezone.id, petId: pet.id, status: sender.isOn) { (success) in
            if !success {
                sender.isOn = !sender.isOn
            }else if success && sender.isOn {
                self.popUp(title: "Hey", msg: "Turned On")
            }else if success && !sender.isOn {
                self.popUp(title: "Hey", msg: "Turned Off")
            }
        }
    }

}



class SafeZoneCell: UITableViewCell {
    @IBOutlet weak var safeZoneImage: UIImageView!
    @IBOutlet weak var iconeImage: UIImageView!
    @IBOutlet weak var safeZoneName: UILabel!
    @IBOutlet weak var switcher: UISwitch!
}

enum Icons: String {
    case zero = "buildings-dark-1x"
    case one = "fountain-dark-1x"
    case two = "girl-and-boy-dark-1x"
    case three = "home-dark-1x"
    case four = "palm-tree-shape-dark-1x"
    case five = "park-dark-1x"
}

