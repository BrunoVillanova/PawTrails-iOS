//
//  AddEditSafeZoneViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 22/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddEditSafeZoneViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate, AddEditSafeZoneView {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var iconTextField: UITextField!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var userFocusButton: UIButton!
    @IBOutlet weak var petFocusButton: UIButton!
    @IBOutlet weak var loadingFocus: UIActivityIndicatorView!
    
    @IBOutlet weak var squareButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var activeSwitch: UISwitch!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    fileprivate var opened:CGFloat = 360.0, closed:CGFloat = 600
    
    fileprivate var shape:Shape = Shape.circle
    
    fileprivate var changingRegion = false
    
    fileprivate var focused = true
    
    fileprivate var fence:Fence!
    fileprivate let fenceSide: Double = 50.0 //meters
    fileprivate var fenceDistance:Int = 50 //meters
    
    fileprivate var  manager = CLLocationManager()
    
    fileprivate let presenter = AddEditSafeZonePresenter()
    
    fileprivate var petLocation:MKLocation? = nil
    fileprivate var updatingPetLocation = false
    
    var safezone: SafeZone?
    var petId: Int16!
    var isOwner: Bool!
    var fromMap: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        blurView.round(radius: 18)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.mapType = .hybrid
        mapView.delegate = self
        
        manager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined { manager.requestWhenInUseAuthorization() }
        
        loadingFocus.isHidden = true
        loadingFocus.hidesWhenStopped = true
        
        //set view position for screen size
        opened = view.frame.height - blurView.frame.height - 7.0
        closed = view.frame.height - 70.0
        
        if let safezone = safezone {
            navigationItem.title = "Edit \(safezone.name!)"
            
            nameTextField.text = safezone.name
            if let shape = Shape(rawValue: safezone.shape) {
                self.shape = shape
            }
            activeSwitch.isOn = safezone.active
            
            if !isOwner {
                userFocusButton.isHidden = true
                petFocusButton.isHidden = true
                nameTextField.isEnabled = false
                iconTextField.isEnabled = false
                circleButton.isEnabled = false
                squareButton.isEnabled = false
                activeSwitch.isEnabled = false
                removeButton.isHidden = true
            }
        }else{
            navigationItem.title = "Add Safe Zone"
//            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(popAction(sender:)))
            removeButton.isHidden = true
        }
        
        if fromMap {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(dismissAction(sender: )))
        }
        
        self.circleButton.tintColor = shape == .circle ? UIColor.primaryColor() : UIColor.darkGray
        self.squareButton.tintColor = shape == .circle ?  UIColor.darkGray : UIColor.primaryColor()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        if let safezone = safezone {
            
            guard let center = safezone.point1?.coordinates else { return }
            guard let topCenter = safezone.point2?.coordinates else { return }
            
            fence = mapView.load(with: center, topCenter: topCenter, shape: shape, into: view)
            
        }else{
            let sonhugoCoordinate = CLLocationCoordinate2D(latitude: 39.592217, longitude: 2.662322)
            mapView.centerOn(sonhugoCoordinate, with: 50, animated: false)
            fence = mapView.load(with: sonhugoCoordinate, shape: shape, into: view)
        }
        updateFenceDistance()
        self.blurView(.close)
    }
    
    deinit {
        presenter.deteachView()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if updatingPetLocation {
            presenter.stopPetGPSUpdates()
        }
       
    }

    
    func geoCodeFence() -> (Point,Point) {
        
        let point1 = Point(coordinates: mapView.convert(fence.center, toCoordinateFrom: view))
        let point2 = Point(coordinates: mapView.convert(fence.topCenter, toCoordinateFrom: view))
        return (point1, point2)
    }
    
    @IBAction func squareAction(_ sender: UIButton) {
        circleButton.tintColor = UIColor.darkGray
        squareButton.tintColor = UIColor.primaryColor()
        fence.shape = .square
        shape = .square
    }
    
    @IBAction func circleAction(_ sender: UIButton) {
        circleButton.tintColor = UIColor.primaryColor()
        squareButton.tintColor = UIColor.darkGray
        fence.shape = .circle
        shape = .circle
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        if let petId = petId {
            if fence.isIdle {
                presenter.addEditSafeZone(safezoneId: safezone?.id ?? -1, name: nameTextField.text, shape: shape, active: activeSwitch.isOn, points: geoCodeFence(), into: petId)
            }else{
                alert(title: "", msg: "The area is too small. Please, zoom out.", type: .red)
            }
        }
    }
    
    @IBAction func removeAction(_ sender: UIButton) {
        if let petId = petId, let id = safezone?.id {
            popUpDestructive(title: "Remove \(safezone?.name ?? "Safe Zone")", msg: "Do you want to remove this safe zone?", cancelHandler: nil, proceedHandler: { (proceed) in
                self.presenter.removeSafeZone(id, into: petId)
            })
        }
    }
    
    @IBAction func userFocusAction(_ sender: UIButton) {
        focused = false
        
        if !mapView.userLocation.coordinate.isDefaultZero {
            mapView.centerOn(mapView.userLocation.coordinate, with: 51, animated: true)
        }else{
            let status = CLLocationManager.authorizationStatus()
            if status == .notDetermined {
                manager.requestWhenInUseAuthorization()
            }else if status == .denied {
                popUpUserLocationDenied()
            }else {
                beginLoadingLocation()
                manager.requestLocation()
            }
        }
    }
    
    @IBAction func petFocusAction(_ sender: UIButton) {
        focused = false
        beginLoadingLocation()
        loadPetLocation()
    }
    
    func loadPetLocation(){

        if !updatingPetLocation {
            updatingPetLocation = true
            presenter.startPetsGPSUpdates { (data) in
                if !self.focused { self.loadPet(coordinates: data.point.coordinates) }
            }
        }

        if let data = SocketIOManager.Instance.getPetGPSData(id: petId) {
            loadPet(coordinates: data.point.coordinates)
        }
    }
    
    func loadPet(coordinates:CLLocationCoordinate2D){
        self.focused = true
        if let petLocation = self.petLocation {
            petLocation.move(coordinate: coordinates)
        }else{
            self.petLocation = MKLocation(id: MKLocationId.init(id: 0, type: .pet), coordinate: coordinates)
            self.mapView.addAnnotation(self.petLocation!)
        }
        endLoadingLocation()
        self.mapView.centerOn(coordinates, with: 51, animated: true)
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        var y = sender.location(in: view).y
        
        let isOpening = sender.translation(in: self.view).y < 0
        
        if isOpening && y < opened {
            let distance = abs(y - opened)
            y += distance * 0.5
        }
        
        topConstraint.constant = y
        
        if sender.state == .ended { blurView(isOpening ? .open : .close, speed: 0.5)  }
    }
    
    //MARK: - AddEditSafeZoneView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: "", msg: error.msg)
    }
    
    func success() {
        if let profile = navigationController?.viewControllers.first(where: { $0 is PetProfileTableViewController}) as? PetProfileTableViewController {
            profile.reloadSafeZones()
            navigationController?.popToViewController(profile, animated: true)
        }
    }
    
    func missingName() {
        nameTextField.becomeFirstResponder()
        nameTextField.shake()
    }
    
    func beginLoadingContent() {
        showLoadingView()
    }
    
    func endLoadingContent() {
        hideLoadingView()
    }
    
    
    //MARK:- User Location Manager
    
    func beginLoadingLocation(){
        userFocusButton.isHidden = true
        petFocusButton.isHidden = true
        loadingFocus.startAnimating()
        loadingFocus.isHidden = false
    }
    
    func endLoadingLocation() {
        loadingFocus.stopAnimating()
        userFocusButton.isHidden = false
        petFocusButton.isHidden = false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined || status == .denied {
            alert(title: "", msg: "User location not granted", type: .blue)
        }else if !focused {
            manager.requestLocation()
            beginLoadingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first, !focused {
            focused = true
            mapView.centerOn(location.coordinate, with: 51, animated: true)
            endLoadingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if !focused {
            endLoadingLocation()
            alert(title: "", msg: "User location failed", type: .red)
        }
    }
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if fence != nil {
            updateFenceDistance()
            if !fenceDistanceIsIdle() && !changingRegion {
                changingRegion = true
                updateFenceDistance()
                changingRegion = false
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return mapView.getRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapView.getAnnotationView(annotation: annotation)
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
            doneAction(nil)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Helpers
    
    func updateFenceDistance() {
        if let fence = fence {
            let x0y0 = mapView.convert(CGPoint(x: fence.x0, y: fence.y0), toCoordinateFrom: view)
            let xfy0 = mapView.convert(CGPoint(x: fence.xf, y: fence.y0), toCoordinateFrom: view)
            fenceDistance = Int(round(x0y0.location.distance(from: xfy0.location)))
            fence.isIdle = fenceDistanceIsIdle()
            self.distanceLabel.text = fenceDistance < 1000 ? "\(fenceDistance) m" : "\(Double(fenceDistance)/1000.0) km"
        }
    }
    
    func fenceDistanceIsIdle() -> Bool {
        return fenceDistance >= Int(fenceSide)
    }
    
    func keyboardWillShow(notification:Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        UIView.animate(withDuration: 1) {
            self.blurView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
    }
    
    func keyboardWillHide(notification:Notification) {
        UIView.animate(withDuration: 1) {
            self.blurView.transform = CGAffineTransform.identity
        }
    }
    
    // MARK: - AnimationHelpers
    
    enum blurViewAction {
        case open, close
        
        init(direction:Int) {
            self = direction < 0 ? .open : .close
        }
    }
    
    func blurView(_ action:blurViewAction, speed:Double = 1, animated:Bool = true){
        
        self.topConstraint.constant = action == .open ? self.opened : self.closed
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
