//
//  HomeViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit

class HomeViewController: UIViewController, HomeView, UIGestureRecognizerDelegate, MKMapViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchRightConstraint: NSLayoutConstraint!

    @IBOutlet weak var searchResultsView: UIVisualEffectView!
    @IBOutlet weak var searchTableView: UITableView!
    
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var topConstraintBlurView: NSLayoutConstraint!
    
    @IBOutlet weak var petDetailView: UIView!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var batteryImageView: UIImageView!
    @IBOutlet weak var signalImageView: UIImageView!
    @IBOutlet weak var petTitleLabel: UILabel!
    @IBOutlet weak var petSubtitleLabel: UILabel!
    @IBOutlet weak var startTripButton: UIButton!
    
    @IBOutlet weak var safeZoneDetailView: UIView!
    @IBOutlet weak var safeZoneTitleLabel: UILabel!
    @IBOutlet weak var showSafeZoneButton: UIButton!
    
    
    fileprivate let presenter = HomePresenter()
    
    fileprivate var opened:CGFloat = 415.0, closed:CGFloat = 600
    
    fileprivate let closedSearch:CGFloat = 299, openedSearch:CGFloat = 0
    
    fileprivate var annotations = [MKLocationId:MKLocation]()
    
    var data = [searchElement]()
    
    var selectedPet: Pet?
    var selectedSafeZone: SafeZone?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.attachView(self)
        
        setTopBar()

        mapView.showsScale = false
        mapView.showsUserLocation = false

        topConstraintBlurView.constant = closed
        blurView.round(radius: 18)

        petDetailView.isHidden = true
        petImageView.circle()
        batteryImageView.circle()
        signalImageView.circle()
        startTripButton.round()
        
        safeZoneDetailView.isHidden = true
        showSafeZoneButton.round()

        searchView.round()
        searchBar.backgroundColor = UIColor.orange().withAlphaComponent(0.8)
        if let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField, let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
            
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .white
            textFieldInsideSearchBar.clearButtonMode = .never
        }
        
        searchBar.showsCancelButton = false
        searchResultsView.round()
        searchResultsView.isHidden = true
        searchTableView.tableFooterView = UIView()
     }
    
    deinit {
        self.presenter.deteachView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.getPets()
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        var y = sender.location(in: view).y
        
        let isOpening = sender.translation(in: self.view).y < 0
        
        if isOpening && y < opened {
            let distance = abs(y - opened)
            y += distance * 0.5
        }
        
        topConstraintBlurView.constant = y
        
        if sender.state == .ended { perform(action: isOpening ? .open : .close, speed: 0.5)  }
    }
    
    @IBAction func startTripAction(sender: UIButton?){
        
        if let selected = selectedPet {
            presentPet(selected)
        }
    }
    
    @IBAction func showSafeZoneAction(sender: UIButton?){
        
        if let selected = selectedSafeZone {
            presentSafeZone(selected)
        }
    }

    // MARK: - HomeView
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func loadMapElements(){
        // Pets
        for pet in presenter.pets {
            let location = CLLocationCoordinate2D.CorkRandom
            let id = MKLocationId(id: pet.id, type: .pet)
            let color = pet.isOwner ? UIColor.orange() : UIColor.darkGray
            
            if annotations[id] == nil {
                startTracking(id, coordinate: location, color: color)
                print(id)
                launchSocketIO(for: id)
            }else{
                updateTracking(id, coordinate: location)
            }
        }
        
        // SafeZones
        for safezone in presenter.safeZones {
            
            if let location = safezone.point1?.coordinates {
                
                let id = MKLocationId(id: safezone.id, type: .safezone)
                let color = UIColor.green
                
                if annotations[id] == nil {
                    startTracking(id, coordinate: location, color: color)
                }else{
                    updateTracking(id, coordinate: location)
                }
            }
        }
        focusOnPets()
    }
    
    func launchSocketIO(for key:MKLocationId){

        SocketIOManager.Instance.getPetGPSData(id: key.id, withUpdates: true, callback: { (data) in
                if let data = data {
                    print("Update Position \(data.point.toDict) \(key.id)")
                    self.updateTracking(key, coordinate: data.point.coordinates)
                    if !(!self.petDetailView.isHidden || !self.safeZoneDetailView.isHidden) {
                        DispatchQueue.main.async {
                            self.focusOnPets()
                        }
                    }
                }
            })
    }
    
    func reload() {
        self.petTitleLabel.text = self.presenter.user.name
        self.petSubtitleLabel.text = self.presenter.user.surname
    }
    
    func startTracking(_ id: MKLocationId, coordinate:CLLocationCoordinate2D, color: UIColor) {
        self.annotations[id] = MKLocation(id: id, coordinate: coordinate, color: color)
        self.mapView.addAnnotation(self.annotations[id]!)
    }
    
    func updateTracking(_ id: MKLocationId, coordinate:CLLocationCoordinate2D) {
        self.annotations[id]?.move(coordinate:coordinate)
    }
    
    func stopTracking(_ id: MKLocationId) {
        guard let a = self.annotations[id] else {
//            self.errorMessage(ErrorMsg(title:"", msg:""))
            return
        }
        self.mapView.removeAnnotation(a)
        self.annotations.removeValue(forKey: id)
    }
    
    func userNotSigned() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func noPetsFound() {
        alert(title: "", msg: "No pets found", type: .blue)
    }
    
    // MARK: - Connection Notifications
    
    func connectedToNetwork() {
        hideNotification()
    }
    
    func notConnectedToNetwork() {
        showNotification(title: Message.Instance.connectionError(type: .NoConnection), type: .red)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapView.getAnnotationView(annotation: annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation as? MKLocation {
            
            mapView.centerOn(annotation.coordinate, animated: true)
            
            switch annotation.id.type {
            case .pet:
                if let pet = presenter.pets.first(where: { $0.id == annotation.id.id }) {
                    showPetDetails(pet)
                }
            case .safezone:
                if let safezone = presenter.safeZones.first(where: { $0.id == annotation.id.id }) {
                    showSafeZoneDetails(safezone)
                }
            default:
                break
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        focusOnPets()
    }
    
    func focusOnPets(){
        let coordinates = Array(self.annotations.values).filter({ $0.id.type == .pet }).map({ $0.coordinate })
        mapView.setVisibleMapFor(coordinates)
    }
    
    func showPetDetails(_ pet: Pet) {
        
        safeZoneDetailView.isHidden = true
        petDetailView.isHidden = false
        
        if let data = pet.image {
            petImageView.image = UIImage(data: data)
        }
        petTitleLabel.text = pet.name
        petSubtitleLabel.text = pet.breeds
        selectedPet = pet
        perform(action: .open)
    }
    
    func showSafeZoneDetails(_ safezone: SafeZone) {
        
        safeZoneDetailView.isHidden = false
        petDetailView.isHidden = true

        safeZoneTitleLabel.text = safezone.name
        selectedSafeZone = safezone
        perform(action: .open)
    }
    
    func getNavigationController() -> UINavigationController {
        let nc = UINavigationController()
        nc.navigationBar.barTintColor = UIColor.orange()
        nc.navigationBar.tintColor = UIColor.white
        nc.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        return nc
    }
    
    func presentPet(_ pet: Pet) {
        
        let nc = getNavigationController()
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PetsPageViewController") as? PetsPageViewController {
            vc.pet = pet
            vc.fromMap = true
            nc.pushViewController(vc, animated: true)
            present(nc, animated: true, completion: nil)
        }
    }
    
    func presentSafeZone(_ safezone: SafeZone) {
        
        let nc = getNavigationController()
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditSafeZoneViewController") as? AddEditSafeZoneViewController {
            vc.safezone = safezone
            vc.petId = safezone.pet?.id
            vc.isOwner = safezone.pet?.isOwner ?? false
            vc.fromMap = true
            nc.pushViewController(vc, animated: true)
            present(nc, animated: true, completion: nil)
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        data.removeAll()
        if searchText != "" {

            for pet in presenter.pets.filter({ $0.name!.lowercased().contains(searchText.lowercased()) }) {
                data.append(searchElement(id: MKLocationId(id: pet.id, type: .pet), object: pet))
            }
            
            for safezone in presenter.safeZones.filter({ $0.name!.lowercased().contains(searchText.lowercased()) }) {
                data.append(searchElement(id: MKLocationId(id: safezone.id, type: .safezone), object: safezone))
            }
        }
        self.searchTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showSearchBar()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    
        if topConstraintBlurView.constant == opened && touches.count == 1, let touch = touches.first {
            let touchPoint = touch.location(in: view)
            if touchPoint.y < opened {
                perform(action: .close)
            }
        }
    }
    
    func showSearchBar(){
        performSearch(action: .open)
    }
    
    func hideSearchBar(){
        searchBar.text = ""
        performSearch(action: .close)
        searchBar.resignFirstResponder()

    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count == 0 ? presenter.pets.count : data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! searchCell
        
        cell.searchImageView.circle()
        cell.searchImageView.backgroundColor = UIColor.orange()
        
        var name: String?
        var image: Data?
        
        if data.count == 0 {
            let pet = presenter.pets[indexPath.row]
            
            name = pet.name
            image = pet.image
            
        }else {
            
            let element = data[indexPath.row]
            
            if element.id.type == .pet, let pet = element.object as? Pet {
                
                name = pet.name
                image = pet.image
                
            }else if element.id.type == .safezone, let safezone = element.object as? SafeZone {
                
                name = safezone.name
                image = Data()
                
            }else{
                
                name = nil
                image = nil
            }
        }
        cell.searchNameLabel?.text = name
        if let image = image { cell.searchImageView?.image = UIImage(data: image) }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if data.count == 0 {
            let pet = presenter.pets[indexPath.row]
            hideSearchBar()
            showPetDetails(pet)
        }else {
            let element = data[indexPath.row]
            
            if let coordinate = annotations[element.id]?.coordinate {
                mapView.centerOn(coordinate, animated: true)
            }
            
            if element.id.type == .pet, let pet = element.object as? Pet {
                
                hideSearchBar()
                showPetDetails(pet)
            }else if element.id.type == .safezone, let safezone = element.object as? SafeZone {
                
                hideSearchBar()
                showSafeZoneDetails(safezone)
            }
        }
    }

    
    // MARK: - AnimationHelpers
    
    enum Action {
        case open, close
    }
    
    func perform(action:Action, speed:Double = 1, animated:Bool = true){
        
        self.topConstraintBlurView.constant = action == .open ? self.opened : self.closed
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            if action == .close {
                self.focusOnPets()
            }
        }
    }

    func performSearch(action:Action) {
        
        UIView.animate(withDuration: 0.5, animations: { 
            self.searchRightConstraint.constant = action == .open ? self.openedSearch : self.closedSearch
            self.searchBar.showsCancelButton = action == .open
            self.view.layoutIfNeeded()
            if action == .close {
                self.searchResultsView.isHidden = true
            }
        }) { (success) in
            if action == .open {
                self.searchTableView.reloadData()
                self.searchResultsView.isHidden = false
            }
        }
    }
}

struct searchElement {
    var id: MKLocationId
    var object: Any
}

enum pinType: Int {
    case pet = 0, safezone, pi
}

class MKLocationId: Hashable {
    var id: Int16
    var type: pinType
    
    init(id : Int16, type: pinType) {
        self.id = id
        self.type = type
    }
    
    var hashValue: Int {
        return id.hashValue ^ type.hashValue
    }
    
    static func == (lhs: MKLocationId, rhs: MKLocationId) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }

}


class MKLocation: MKPointAnnotation {
    var color:UIColor
    var id: MKLocationId
    
    init(id : MKLocationId, coordinate:CLLocationCoordinate2D, color: UIColor = UIColor.random()) {
        self.id = id
        self.color = color
        super.init()
        self.coordinate = coordinate
    }
    
    func move(coordinate:CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
    
}



class searchCell: UITableViewCell {
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchNameLabel: UILabel!
}









































