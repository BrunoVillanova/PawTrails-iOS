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

class AddEditSafeZoneViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate,/* CLLocationManagerDelegate,*/ AddEditSafeZoneView {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var iconTextField: UITextField!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var userFocusButton: UIButton!
    @IBOutlet weak var petFocusButton: UIButton!
    @IBOutlet weak var squareButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var activeSwitch: UISwitch!
    
    @IBOutlet weak var bottomContraints: NSLayoutConstraint!
    
    fileprivate var opened:CGFloat = -255.0, closed:CGFloat = -60.0
    
    fileprivate var isCircle:Bool = true
    
    fileprivate var changingRegion = false
    
    fileprivate var fence:Fence!
    fileprivate let fenceSide: Double = 50.0 //meters
    fileprivate var fenceDistance:Int = 50
    fileprivate var minimumAltitude: CLLocationDistance!
    
    fileprivate var  manager = CLLocationManager()

    fileprivate let presenter = AddEditSafeZonePresenter()
    
    var safezone: SafeZone?
    var petId: Int16!
    
    var focused = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        mapView.showsUserLocation = false
        mapView.showsCompass = false
        mapView.mapType = .satellite
        
        if let safezone = safezone {
            navigationItem.title = "Edit Safe Zone"

            nameTextField.text = safezone.name
            isCircle = safezone.shape
            activeSwitch.isOn = safezone.active

        }else{
            navigationItem.title = "New Safe Zone"
            removeButton.isHidden = true
        }
        
        self.circleButton.tintColor = isCircle ? UIColor.orange() : UIColor.darkGray
        self.squareButton.tintColor = isCircle ?  UIColor.darkGray : UIColor.orange()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let safezone = safezone {
            
            guard let center = safezone.point1?.coordinates else { return }
            guard let topCenter = safezone.point2?.coordinates else { return }

            minimumAltitude = MKMapView.minimumAltitude(for: 50)
            fence = mapView.load(with: center, topCenter: topCenter, isCircle: isCircle, into: view)
            
        }else{
            let sonhugoCoordinate = CLLocationCoordinate2D(latitude: 39.592217, longitude: 2.662322)
            minimumAltitude = mapView.getMinimumAltitude(for: 50, coordinate: sonhugoCoordinate)
            fence = mapView.load(with: sonhugoCoordinate, isCircle: isCircle, into: view)
        }
        updateFenceDistance()
        self.blurView(.close)
    }
    
    deinit {
        presenter.deteachView()
        NotificationCenter.default.removeObserver(self)
    }
    
    func geoCodeFence() -> (Point,Point) {

        let point1 = Point(coordinates: mapView.convert(fence.center, toCoordinateFrom: view))
        let point2 = Point(coordinates: mapView.convert(fence.topCenter, toCoordinateFrom: view))
        return (point1, point2)
    }

    @IBAction func squareAction(_ sender: UIButton) {
        circleButton.tintColor = UIColor.darkGray
        squareButton.tintColor = UIColor.orange()
        fence.isCircle = false
        isCircle = false
    }
    
    @IBAction func circleAction(_ sender: UIButton) {
        circleButton.tintColor = UIColor.orange()
        squareButton.tintColor = UIColor.darkGray
        fence.isCircle = true
        isCircle = true
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        if let petId = petId {
            presenter.addEditSafeZone(safezoneId: safezone?.id ?? -1, name: nameTextField.text, isCircle: isCircle, active: activeSwitch.isOn, points: geoCodeFence(), into: petId)
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
        mapView.showsUserLocation = true
//        let status = CLLocationManager.authorizationStatus()
//        if status == .notDetermined {
//            manager.requestWhenInUseAuthorization()
//        }else if status == .denied {
//            
//        }else {
//            manager.requestLocation()
//        }
    }

    @IBAction func petFocusAction(_ sender: UIButton) {
        focused = false
        alert(title: "", msg: "Under Construction", type: .blue)

    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        let y = sender.translation(in: self.view).y / 2.5
        if (y < 0 && bottomContraints.constant > opened) || (y > 0 && bottomContraints.constant < closed) { bottomContraints.constant += y }
        
        if sender.state == .ended {
            blurView(y < 0 ? .open : .close, speed: 0.5)
        }
    }
    
    //MARK: - AddEditSafeZoneView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: "", msg: error.msg)
    }
    
    func success() {
        if let petProfile = navigationController?.viewControllers.first(where: { $0 is PetsPageViewController}) as? PetsPageViewController {
            navigationController?.popToViewController(petProfile, animated: true)
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
    
    // MARK: - Connection Notifications
    
    func connectedToNetwork() {
        hideNotification()
    }
    
    func notConnectedToNetwork() {
        showNotification(title: Message.Instance.connectionError(type: .NoConnection), type: .red)
    }
    
    //MARK:- User Location Manager
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !mapView.userLocation.coordinate.isDefaultZero && !focused {
            focused = true
            mapView.centerOn(userLocation.coordinate, with: 50, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        alert(title: "", msg: "Couldn't Locate User", type: .red)
    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .notDetermined || status == .denied {
//            alert(title: "", msg: "User location not granted", type: .blue)
//        }else{
//            manager.requestLocation()
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        if let location = locations.first, !focused {
//            focused = true
//            mapView.centerOn(location.coordinate, with: 50, animated: true)
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        alert(title: "", msg: "User location failed", type: .red)
//    }


    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if fence != nil {
            updateFenceDistance()
            if !fenceDistanceIsIdle() && !changingRegion {
                changingRegion = true
                adjustZoom()
                updateFenceDistance()
                changingRegion = false
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return mapView.getRenderer(overlay: overlay)
    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if let annotation = annotation as? MKLocation {
//            // Better to make this class property
//            let annotationIdentifier = "mkl"
//            
//            var annotationView: MKAnnotationView?
//            if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
//                annotationView = dequeuedAnnotationView
//                annotationView?.annotation = annotation
//            }
//            else {
//                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            }
//            
//            if let annotationView = annotationView {
//                annotationView.backgroundColor = annotation.color
//                annotationView.frame.size = CGSize(width: 15, height: 15)
//                annotationView.circle()
//            }
//            return annotationView
//        }
//        return nil
//    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Helpers
    
    func updateFenceDistance() {
        if let fence = fence {
            let x0y0 = mapView.convert(CGPoint(x: fence.x0, y: fence.y0), toCoordinateFrom: self.view)
            let xfy0 = mapView.convert(CGPoint(x: fence.xf, y: fence.y0), toCoordinateFrom: self.view)
            fenceDistance = Int(round(x0y0.location.distance(from: xfy0.location)))
            
            self.distanceLabel.text = fenceDistance < 1000 ? "\(fenceDistance) m" : "\(Double(fenceDistance)/1000.0) km"
        }
    }

    func fenceDistanceIsIdle() -> Bool {
        return fenceDistance > Int(fenceSide)
    }
    
    func adjustZoom() {
        if minimumAltitude != nil {
            let c = mapView.camera.copy() as! MKMapCamera
            c.altitude = minimumAltitude
            mapView.setCamera(c, animated: true)
        }
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
        
        if (self.bottomContraints.constant == closed && action == .close) || (self.bottomContraints.constant == opened && action == .open) { return }
        
        if animated {
            UIView.animate(withDuration: speed, animations: {
                let dy = action == .open ? self.blurView.frame.minY - self.blurView.center.y : self.blurView.center.y - self.blurView.frame.minY
                self.blurView.transform = CGAffineTransform(translationX: 0, y: dy)
            }) { (done) in
                self.bottomContraints.constant = action == .open ? self.opened : self.closed
                self.blurView.transform = CGAffineTransform.identity
            }
        }else{
            self.bottomContraints.constant = action == .open ? self.opened : self.closed
        }
    }

    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
