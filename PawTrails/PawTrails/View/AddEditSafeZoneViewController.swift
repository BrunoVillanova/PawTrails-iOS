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

class AddEditSafeZoneViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var iconTextField: UITextField!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var squareButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    
    fileprivate var isCircle:Bool = true
    
    fileprivate var changingRegion = false
    
    fileprivate var fence:Fence!
    fileprivate let fenceSide: Double = 25.0
    fileprivate var fenceDistance:Int = 25
    fileprivate var altitude: CLLocationDistance!
    
    fileprivate var manager = CLLocationManager()
    
    var safezone: SafeZone!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        
        self.circleButton.tintColor = UIColor.darkGray
        self.squareButton.tintColor = UIButton.appearance().tintColor
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined || status == .denied {
            let dublinCoordinates = CLLocationCoordinate2D(latitude: 53.3498, longitude: 6.2603)
            self.setUpMap(coordinates: dublinCoordinates)
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !mapView.userLocation.coordinate.isDefaultZero && mapView.showsUserLocation {
            setUpMap(coordinates: mapView.userLocation.coordinate)
        }
    }
    
    func setUpMap(coordinates: CLLocationCoordinate2D) {
        if fence == nil {
            mapView.centerOn(coordinates, with: 50, animated: true)
            mapView.showsUserLocation = false
            altitude = mapView.camera.altitude
            
            let region = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, fenceSide, fenceSide)
            let frame = mapView.convertRegion(region, toRectTo: self.view)
            fence = Fence(frame: frame, isCircle: isCircle)
            mapView.layer.addSublayer(fence.layer)
            updateFenceDistance()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
//    func getFenceLimits() {
//        let s = fenceView.frame.height/2.0
//        let x0 = self.view.center.x
//        let y0 = self.view.center.y
//        var corners = [CLLocationCoordinate2D]()
////        if isSquare {
////            corners.append(mapView.convert(CGPoint.init(x: x0 - s, y: y0 - s), toCoordinateFrom: self.view))    // up   left
////            corners.append(mapView.convert(CGPoint.init(x: x0 + s, y: y0 - s), toCoordinateFrom: self.view))    // up   right
////            corners.append(mapView.convert(CGPoint.init(x: x0 + s, y: y0 + s), toCoordinateFrom: self.view))    // down right
////            corners.append(mapView.convert(CGPoint.init(x: x0 - s, y: y0 + s), toCoordinateFrom: self.view))    // down left
////        }else{
//            corners.append(mapView.convert(CGPoint.init(x: x0, y: y0), toCoordinateFrom: self.view))            // center
//            corners.append(mapView.convert(CGPoint.init(x: x0, y: y0 - s), toCoordinateFrom: self.view))        // center up
////        }
//        for i in corners {
//            print(i)
//            let note = MKPointAnnotation()
//            note.coordinate = i
//            mapView.addAnnotation(note)
//        }
//    }
    

    @IBAction func squareAction(_ sender: UIButton) {
        self.circleButton.tintColor = UIColor.darkGray
        self.squareButton.tintColor = UIButton.appearance().tintColor
        self.fence.isCircle = false
    }
    
    @IBAction func circleAction(_ sender: UIButton) {
        self.circleButton.tintColor = UIButton.appearance().tintColor
        self.squareButton.tintColor = UIColor.darkGray
        self.fence.isCircle = true
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        dismissBarAction(sender: sender)
    }

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
        
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.5)
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if #available(iOS 10.0, *), (nameTextField.text != nil){
//            if let emojis = EmojiManager.Instance.getEmojis(from: nameTextField.text!) {
//                self.iconTextField.placeholder = emojis.first
//            }
//        }
//    }
    
    // MARK: - Helper
    
    func updateFenceDistance() {
        let x0y0 = mapView.convert(CGPoint(x: fence.x0, y: fence.y0), toCoordinateFrom: self.view)
        let xfy0 = mapView.convert(CGPoint(x: fence.xf, y: fence.y0), toCoordinateFrom: self.view)
        fenceDistance = Int(round(x0y0.location.distance(from: xfy0.location)))
        self.distanceLabel.text = "\(fenceDistance) meters"
    }

    func fenceDistanceIsIdle() -> Bool {
        return fenceDistance > Int(fenceSide)
    }
    
    func adjustZoom() {
        if altitude != nil {
            let c = mapView.camera.copy() as! MKMapCamera
            c.altitude = altitude
            mapView.setCamera(c, animated: true)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
