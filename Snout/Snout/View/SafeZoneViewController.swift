//
//  SafeZoneViewController.swift
//  Snout
//
//  Created by Marc Perello on 22/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class SafeZoneViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var iconTextField: UITextField!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var fenceView: UIView!
    @IBOutlet weak var squareButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    
    fileprivate var isSquare:Bool = true
    fileprivate var distance:Int!
    
    fileprivate var changingRegion = false
    fileprivate let fenceSide = 50.0
    fileprivate var latitudeValue:Double = 200.0
    fileprivate var longitudeValue:Double = 200.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let note = MKPointAnnotation()
        note.coordinate = CLLocationCoordinate2DMake(39.6131615,2.6314731)
//        mapView.addAnnotation(note)
//        mapView.setCenter(note.coordinate, animated: true)
//        getFenceLimits()
        self.circleButton.tintColor = UIColor.darkGray
        self.squareButton.tintColor = UIButton.appearance().tintColor
        setAltitudeValue()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        setAltitudeValue()
        updateDistance()
        if mapView.camera.altitude < latitudeValue && !changingRegion {
            changingRegion = true
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, latitudeValue, longitudeValue), animated: true)
            changingRegion = false
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
    
    func getFenceLimits() {
        let s = fenceView.frame.height/2.0
        let x0 = self.view.center.x
        let y0 = self.view.center.y
        var corners = [CLLocationCoordinate2D]()
        if isSquare {
            corners.append(mapView.convert(CGPoint.init(x: x0 - s, y: y0 - s), toCoordinateFrom: self.view))    // up   left
            corners.append(mapView.convert(CGPoint.init(x: x0 + s, y: y0 - s), toCoordinateFrom: self.view))    // up   right
            corners.append(mapView.convert(CGPoint.init(x: x0 + s, y: y0 + s), toCoordinateFrom: self.view))    // down right
            corners.append(mapView.convert(CGPoint.init(x: x0 - s, y: y0 + s), toCoordinateFrom: self.view))    // down left
        }else{
            corners.append(mapView.convert(CGPoint.init(x: x0, y: y0), toCoordinateFrom: self.view))            // center
            corners.append(mapView.convert(CGPoint.init(x: x0, y: y0 - s), toCoordinateFrom: self.view))        // center up
        }
        for i in corners {
            print(i)
            let note = MKPointAnnotation()
            note.coordinate = i
            mapView.addAnnotation(note)
        }
    }

    func setAltitudeValue(){
        latitudeValue = Double(view.center.y / (fenceView.frame.height / 2.0)) * fenceSide
        longitudeValue = Double(view.center.x / (fenceView.frame.height / 2.0)) * fenceSide
    }
    
    func updateDistance() {
        let center = mapView.convert(CGPoint.init(x: self.view.center.x, y: self.view.center.y), toCoordinateFrom: self.view)
        let upCenter = mapView.convert(CGPoint.init(x: self.view.center.x, y: self.view.center.y - (fenceView.frame.height/2.0)), toCoordinateFrom: self.view)
        distance = Int(center.location.distance(from: upCenter.location))
        self.distanceLabel.text = distance < 1000 ? "\(distance!) m" : "\(distance!/1000) km"
    }

    
    @IBAction func cancelAction(_ sender: UIButton) {

    }

    @IBAction func squareAction(_ sender: UIButton) {
        self.circleButton.tintColor = UIColor.darkGray
        self.squareButton.tintColor = UIButton.appearance().tintColor
        self.fenceView.resetCorner()
        self.isSquare = true
    }
    @IBAction func circleAction(_ sender: UIButton) {
        self.circleButton.tintColor = UIButton.appearance().tintColor
        self.squareButton.tintColor = UIColor.darkGray
        self.fenceView.circle()
        self.isSquare = false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateDistance()
        if mapView.camera.altitude < latitudeValue && !changingRegion {
            changingRegion = true
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, latitudeValue, longitudeValue), animated: true)
            changingRegion = false
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
