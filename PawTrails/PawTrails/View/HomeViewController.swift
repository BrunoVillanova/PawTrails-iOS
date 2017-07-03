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
    @IBOutlet weak var searchResultsHeight: NSLayoutConstraint!
    @IBOutlet weak var searchTableView: UITableView!
    
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var topConstraintBlurView: NSLayoutConstraint!
    
    @IBOutlet weak var slideIndicator: UILabel!
    @IBOutlet weak var blurViewCloseButton: UIButton!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var batteryImageView: UIImageView!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var signalImageView: UIImageView!
    @IBOutlet weak var signalLabel: UILabel!
    @IBOutlet weak var petTitleLabel: UILabel!
    @IBOutlet weak var petSubtitleLabel: UILabel!
    @IBOutlet weak var startTripButton: UIButton!
    @IBOutlet weak var petProfileButton: UIButton!
    @IBOutlet weak var petActivityButton: UIButton!
    
    
    fileprivate let presenter = HomePresenter()
    
    fileprivate var openedHalf:CGFloat = 405.0, openedFull:CGFloat = 155.0, closed:CGFloat = 600
    
    fileprivate var closedSearch:CGFloat = 299, openedSearch:CGFloat = 0
    
    fileprivate var annotations = [MKLocationId:MKLocation]()
    
    var data = [searchElement]()
    
    var selectedPet: Pet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.attachView(self)
        
        setTopBar()
        
        mapView.showsScale = false
        mapView.showsUserLocation = false
        
        topConstraintBlurView.constant = closed
        blurView.round(radius: 18)
        
        blurView.isHidden = true
        slideIndicator.round()
        blurViewCloseButton.circle()
        petImageView.circle()
        batteryImageView.circle()
        signalImageView.circle()
        startTripButton.round()
        startTripButton.backgroundColor = UIColor.primaryColor()
        startTripButton.tintColor = UIColor.secondaryColor()
        petProfileButton.round()
        petActivityButton.round()
        petProfileButton.border(color: UIColor.primaryColor(), width: 2.0)
        petActivityButton.border(color: UIColor.primaryColor(), width: 2.0)
        petProfileButton.tintColor = UIColor.primaryColor()
        petActivityButton.tintColor = UIColor.primaryColor()
        
        searchView.round()
        searchBar.backgroundColor = UIColor.primaryColor().withAlphaComponent(0.8)
        if let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField, let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
            
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .white
            textFieldInsideSearchBar.clearButtonMode = .never
        }
        
        searchBar.showsCancelButton = false
        searchResultsView.round()
        searchResultsView.isHidden = true
        searchTableView.tableFooterView = UIView()
        
        //update card position for view size
        let bar:CGFloat = 60.0
        openedFull = view.frame.height - bar - 450.0
        openedHalf = view.frame.height - bar - 200.0
        closed = view.frame.height - bar
        
        closedSearch = view.frame.width - searchView.frame.width - 32.0
        searchRightConstraint.constant = closedSearch
        
        searchResultsHeight.constant = view.frame.height - 226.0 - searchResultsView.frame.origin.y
        
        reloadPets()
    }
    
    func reloadPets(){
        presenter.getPets()
    }
    
    deinit {
        self.presenter.deteachView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.startPetsListUpdates()
        presenter.startPetsGPSUpdates { (id, point) in
            self.load(id: id, point: point)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.stopPetListUpdates()
        presenter.stopPetGPSUpdates()
    }
    
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        var y = sender.location(in: view).y
        
        let isOpening = sender.translation(in: self.view).y < 0
        
        if isOpening && y < openedFull {
            let distance = abs(y - openedFull)
            y += distance * 0.5
        }
        
        topConstraintBlurView.constant = y
        
        if sender.state == .ended {
            if isOpening && y < openedHalf {perform(action: .openFull, speed: 0.5)}
            else if isOpening && y > openedHalf || (!isOpening && y < openedHalf) {perform(action: .openHalf, speed: 0.5)}
            else {perform(action: .close, speed: 0.5)}
        }
    }
    
    @IBAction func closeBlurViewAction(_ sender: UIButton) {
        perform(action: .close)
    }
    
    @IBAction func startTripAction(sender: UIButton?){
        alert(title: "", msg: "Under Construction", type: .blue)
    }
    
    @IBAction func showPetProfileAction(_ sender: UIButton) {
        if let selected = selectedPet {
            presentPet(selected)
        }
    }
    
    @IBAction func showPetActivityAction(_ sender: UIButton) {
        if let selected = selectedPet {
            presentPet(selected, activityEnabled: true)
        }
    }
    
    // MARK: - HomeView
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func loadPets(){
       
        var petsIdsToRemove = annotations.map({ $0.key.id })
        
        for pet in presenter.pets {
            
            if let index = petsIdsToRemove.index(of: pet.id) {
                petsIdsToRemove.remove(at: index)
            }
            
            if let point = SocketIOManager.Instance.getGPSData(for: pet.id)?.point {
                load(id: MKLocationId(id: pet.id, type: .pet), point: point)
            }
        }
        for id in petsIdsToRemove {
            if let annotationToRemove = annotations.removeValue(forKey: MKLocationId(id: id, type: .pet)) {
                mapView.removeAnnotation(annotationToRemove)
            }
        }
        focusOnPets()
    }
    
    
    func reload() {
        self.petTitleLabel.text = self.presenter.user.name
        self.petSubtitleLabel.text = self.presenter.user.surname
    }
    
    func load(id: MKLocationId, point: Point){
        if self.annotations[id] == nil {
            self.startTracking(id, coordinate: point.coordinates, color: UIColor.primaryColor())
        }else{
            self.updateTracking(id, coordinate: point.coordinates)
        }
        self.focusOnPets()
    }
    
    func startTracking(_ id: MKLocationId, coordinate:CLLocationCoordinate2D, color: UIColor) {
        self.annotations[id] = MKLocation(id: id, coordinate: coordinate, color: color)
        self.mapView.addAnnotation(self.annotations[id]!)
    }
    
    func updateTracking(_ id: MKLocationId, coordinate:CLLocationCoordinate2D) {
        self.annotations[id]?.move(coordinate:coordinate)
    }
    
    func stopPetTracking(_ id: Int){
        self.annotations.removeValue(forKey: MKLocationId(id:id, type: .pet))
    }
    
    func userNotSigned() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func noPetsFound() {
        alert(title: "", msg: "No pets found", type: .blue)
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
            default:
                break
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        focusOnPets()
    }
    
    func focusOnPets(){
        if !isShowingDetails() {
            let coordinates = Array(self.annotations.values).filter({ $0.id.type == .pet && !$0.coordinate.isDefaultZero }).map({ $0.coordinate })
            mapView.setVisibleMapFor(coordinates)
        }
    }
    
    func showPetDetails(_ pet: Pet) {
        
        blurView.isHidden = false
        
        if let data = pet.image {
            petImageView.image = UIImage(data: data)
        }else{
            petImageView.image = nil
        }
        petTitleLabel.text = pet.name
        let data = SocketIOManager.Instance.getGPSData(for: pet.id)
        petSubtitleLabel.text = data?.locationAndTime ?? data?.point.toString ?? "Unknown"
        signalLabel.text = data?.signalString
        batteryLabel.text = data?.batteryString
        signalImageView.isHidden = data?.signalString == nil
        batteryImageView.isHidden = data?.batteryString == nil
        selectedPet = pet
        perform(action: .openHalf)
    }
    
    func isShowingDetails() -> Bool {
        return self.topConstraintBlurView.constant != self.closed
    }
    
    func presentPet(_ pet: Pet, activityEnabled:Bool = false) {
        
        let nc = UINavigationController()
        
        if activityEnabled {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PetActivityViewController") as? PetActivityViewController {
                vc.pet = pet
                vc.fromMap = true
                nc.pushViewController(vc, animated: true)
                present(nc, animated: true, completion: nil)
            }
        }else{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PetProfileTableViewController") as? PetProfileTableViewController {
                vc.pet = pet
                vc.fromMap = true
                nc.pushViewController(vc, animated: true)
                present(nc, animated: true, completion: nil)
            }
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
        
        if topConstraintBlurView.constant == openedHalf && touches.count == 1, let touch = touches.first {
            let touchPoint = touch.location(in: view)
            if touchPoint.y < openedHalf {
                perform(action: .close)
            }
        }
    }
    
    func showSearchBar(){
        performSearch(action: .openHalf)
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
        cell.searchImageView.backgroundColor = UIColor.primaryColor()
        
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
            }
        }
    }
    
    
    // MARK: - AnimationHelpers
    
    enum Action {
        case openHalf, openFull, close
    }
    
    func perform(action:Action, speed:Double = 1, animated:Bool = true){
        
        self.topConstraintBlurView.constant = self.openedHalf
        if action == .openFull { self.topConstraintBlurView.constant = self.openedFull }
        if action == .close { self.topConstraintBlurView.constant = self.closed }
        
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
            self.searchRightConstraint.constant = action == .openHalf ? self.openedSearch : self.closedSearch
            self.searchBar.showsCancelButton = action == .openHalf
            self.view.layoutIfNeeded()
            if action == .close {
                self.searchResultsView.isHidden = true
            }
        }) { (success) in
            if action == .openHalf {
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
    var id: Int
    var type: pinType
    
    init(id : Int, type: pinType) {
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









































