//
//  SafeZoneViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 22/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Fence: NSObject {
    
    let layer: CALayer
    var isCircle:Bool {
        didSet {
            updateCornerRadius()
        }
    }

    
    init(frame: CGRect, isCircle:Bool) {
        layer = CALayer()
        layer.frame = frame
        layer.backgroundColor =  UIColor.blueSystem().withAlphaComponent(0.5).cgColor
        self.isCircle = isCircle
    }
    
    func setFrame(_ frame:CGRect) {
        layer.frame = frame
        updateCornerRadius()
    }
    
    private func updateCornerRadius(){
        layer.cornerRadius = isCircle ? layer.frame.width / 2.0 : 0.0
    }
    
    var x0: CGFloat {
        return layer.frame.origin.x
    }
    
    var y0: CGFloat {
        return layer.frame.origin.y
    }
    
    var xf: CGFloat {
        return x0 + layer.frame.width
    }
    
    var yf: CGFloat {
        return y0 + layer.frame.height
    }
}

class SafeZoneViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        mapView.showsUserLocation = true
        mapView.showsCompass = false
        
        self.squareButton.tintColor = UIColor.darkGray
        self.circleButton.tintColor = UIButton.appearance().tintColor
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !mapView.userLocation.coordinate.isDefaultZero && mapView.showsUserLocation {
            mapView.centerOn(mapView.userLocation.coordinate, with: 50)
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
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if #available(iOS 10.0, *), (nameTextField.text != nil){
            if let emojis = EmojiManager.Instance.getEmojis(from: nameTextField.text!) {
                self.iconTextField.placeholder = emojis.first
            }
        }
    }
    
    // MARK: - Helper
    
    func updateFenceDistance() {
        let x0y0 = mapView.convert(CGPoint(x: fence.x0, y: fence.y0), toCoordinateFrom: self.view)
        let xfy0 = mapView.convert(CGPoint(x: fence.xf, y: fence.y0), toCoordinateFrom: self.view)
        fenceDistance = Int(round(x0y0.location.distance(from: xfy0.location)))
        self.distanceLabel.text = "\(fenceDistance)"
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
