//
//  Extensions.swift
//  Snout
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

// MARK:- Own Data Management

extension Phone {
    
    var toString:String? {
        
        guard let number = self.number else {
            return nil
        }
        
        guard let country_code = self.country_code else {
            return nil
        }
        return "\(country_code) \(number)"
    }
    
    var toServerDict: [String:Any]? {
        
        guard let number = self.number else {
            return nil
        }
        
        guard let code = self.country_code else {
            return nil
        }
       
        var phoneData = [String:Any]()
        phoneData["number"] = number
        phoneData["country_code"] = code
        return phoneData
    }
    
}

extension Address {
    
    var toString: String? {
        
        let address = self.toStringDict
        
        if address.count == 0 { return nil }
        
        var desc = [String]()
        if address["line0"] != nil && address["line0"] != "" { desc.append(address["line0"]!)}
        if address["line1"] != nil && address["line1"] != "" { desc.append(address["line1"]!)}
        if address["line2"] != nil && address["line2"] != "" { desc.append(address["line2"]!)}
        if address["city"] != nil && address["city"] != "" { desc.append(address["city"]!)}
        if address["postal_code"] != nil && address["postal_code"] != "" { desc.append(address["postal_code"]!)}
        if address["state"] != nil && address["state"] != "" { desc.append(address["state"]!)}
        if address["country"] != nil && address["country"] != "" { desc.append(address["country"]!)}
        return desc.joined(separator: ", ")

    }
    
    func update(with data:[String:String]) {
        for (k,v) in data {
            if self.keys.contains(k) {
                self.setValue(v, forKey: k)
            }
        }
    }

}
// MARK:- Data Management

extension String {
    
    public var isValidEmail:Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailTest.evaluate(with: self)
    }
    
    
    public var isValidPassword:Bool {
        let lower = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
        let upper = CharacterSet(charactersIn: "ABCDEFGHIJKLKMNOPQRSTUVWXYZ")
        let numbers = CharacterSet(charactersIn: "0123456789")
        //        let special = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789").inverted
        return self.rangeOfCharacter(from: lower) != nil && self.rangeOfCharacter(from: upper) != nil && self.rangeOfCharacter(from: numbers) != nil && self.characters.count > 7
    }
    
    public var toDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
    
}

extension Date {
    
    public var toStringShow: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
    public var toStringServer: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}

extension NSDate {
    
    public var toStringShow: String? {
        return (self as Date).toStringShow
    }
    public var toStringServer: String? {
        return (self as Date).toStringServer
    }
}

extension CLLocationCoordinate2D {
    
    public var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    public var isDefaultZero: Bool {
        return self.latitude == 0 && self.longitude == 0 
    }
    
}

extension NSManagedObject {
    
    public var toStringDict: [String:String] {
        var out = [String:String]()
        for k in self.entity.attributesByName.keys {
            if let value = self.value(forKey: k) as? String {
                out[k] = value
            }
        }
        return out
    }
    
    
    public var keys: [String] {
        return Array(self.entity.attributesByName.keys)
    }
    
}

public enum NSPredicateOperation: String {
    case equal = "=="
    case contains = "CONTAINS[cd]"
    case beginsWith = "BEGINSWITH[cd]"
}

extension NSPredicate {
    
    fileprivate enum concatOperation: String {
        case and = "&&"
        case or = "||"
    }
    
    convenience init(_ left:String, _ operation:NSPredicateOperation, _ right:Any) {
        self.init(format: "\(left) \(operation.rawValue) '\(right)'")
    }
    
    func and(_ left:String, _ op:NSPredicateOperation, _ right:Any) -> NSPredicate {
        return concatFormat(.and, left, op, right)
    }
    
    func or(_ left:String, _ op:NSPredicateOperation, _ right:Any) -> NSPredicate {
        return concatFormat(.or, left, op, right)
    }
    
    fileprivate func concatFormat(_ concatOp: concatOperation, _ left:String, _ op:NSPredicateOperation, _ right:Any) -> NSPredicate {
        return NSPredicate(format: "\(self.predicateFormat) \(concatOp.rawValue) \(left) \(op.rawValue) %@", argumentArray: [right])
    }
}

extension Dictionary {
    
    /// Returns a new dictionary filtering the specified keys
    func filtered(by keys:[String]) -> Dictionary {
        
        let out = NSMutableDictionary(dictionary: self)
       
        for key in keys {
            out.removeObject(forKey: key)
        }
        return NSDictionary(dictionary: out) as! Dictionary<Key, Value>
    }
    
}

// MARK:- MapView

extension MKMapView {
    
    func setVisibleMapForAnnotations() {

        if self.annotations.count == 1 {
            self.centerOn(self.annotations.first!.coordinate)
        }else{
            var zoomRect = MKMapRectNull
            for i in self.annotations {
                let point = MKMapPointForCoordinate(i.coordinate)
                zoomRect = MKMapRectUnion(zoomRect, MKMapRectMake(point.x, point.y, 20, 20))
            }
            self.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(UIScreen.main.bounds.height/10, UIScreen.main.bounds.width/10, UIScreen.main.bounds.height/5, UIScreen.main.bounds.width/10), animated: true)
        }
        
    }
    
    func centerOn(_ location: CLLocationCoordinate2D, with regionRadius: CLLocationDistance = 100.0){
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0,regionRadius * 2.0)
            self.setRegion(coordinateRegion, animated: false)
    }
}



// MARK:- View

enum notificationType {
    
    case red, blue, green
    
    var color: UIColor {
        switch self {
        case .red: return UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.8)
        case .green: return UIColor(red: 0, green: 0.5, blue: 0.2, alpha: 0.8)
        default: return UIColor(red: 0, green: 0.478431, blue: 1, alpha: 0.8)
        }
    }
}

extension UIViewController {
    
    func alert(title:String, msg:String, actionTitle: String = "Ok"){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissAction(sender: UIButton){
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissBarAction(sender: UIBarButtonItem){
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // Connection Notifier
    
    func hideNotification() {
        if let notificationView = view.subviews.first(where: { $0.tag == 2 }) {
            notificationView.removeFromSuperview()
        }
    }
    
    func showNotification(title:String, type:notificationType = .blue) {
        
        let viewHeight:CGFloat = 64, labelHeight: CGFloat = 24

        let notificationView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: viewHeight))
        notificationView.backgroundColor = type.color
        notificationView.tag = 2
        
        let label = UILabel(frame: CGRect(x: 0, y: labelHeight, width: self.view.bounds.width, height: 40))
        label.text = title
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        
        notificationView.addSubview(label)
        view.addSubview(notificationView)
    }

    
    // Loading View
    
    func showLoadingView() {
        let loadingView = UIVisualEffectView(frame: view.bounds)
        loadingView.effect = UIBlurEffect.init(style: .extraLight)
        loadingView.tag = 1
        
        let activity = UIActivityIndicatorView(frame: view.bounds)
        activity.activityIndicatorViewStyle = .whiteLarge
        activity.color = UIColor.orange()
        activity.startAnimating()
        activity.tag = 1
        
        loadingView.addSubview(activity)
        
        loadingView.alpha = 0.0
        
        view.addSubview(loadingView)
        
        UIView.animate(withDuration: 0.6) {
            loadingView.alpha = 1.0
        }
    }
    
    func hideLoadingView() {
        if let loadingView = view.subviews.first(where: { $0.tag == 1 }) as? UIVisualEffectView {
            UIView.animate(withDuration: 0.4, animations: {
                loadingView.alpha = 0
            }, completion: { (success) in
                if success {
                    loadingView.removeFromSuperview()
                }
            })
        }
    }
    
    func hideLoadingView(with success:Bool){
        
        let label = UILabel(frame: view.bounds)
        label.text = "✓"
        label.font = UIFont.systemFont(ofSize: 70)
        label.textAlignment = .center
        label.textColor = UIColor.orange()
        
     
        if let loadingView = view.subviews.first(where: { $0.tag == 1 }) as? UIVisualEffectView {

            if let activity = loadingView.subviews.first(where: { $0.tag == 1 }) as? UIActivityIndicatorView {
                activity.removeFromSuperview()
                loadingView.addSubview(label)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: { 
                    self.hideLoadingView()
                })
            }
        }
    }
    
}

extension UIColor {
    
    public static func random() -> UIColor {
        let r = CGFloat(arc4random() % 255)
        let g = CGFloat(arc4random() % 255)
        let b = CGFloat(arc4random() % 255)
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    
    public static func orange() -> UIColor {
        return UIColor(red: 251.0/255.0, green: 141.0/255.0, blue: 43.0/255.0, alpha: 1.0)
    }
    
    public static func blueSystem() -> UIColor {
        return UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    }
    
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-15.0, 15.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    func round(radius:CGFloat = 5) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    func circle() {
        self.layer.cornerRadius = self.frame.height / 2.0
        self.clipsToBounds = true
    }
    
    func resetCorner() {
        self.layer.cornerRadius = 0
        self.clipsToBounds = true
    }
    
    func border(color: UIColor = UIColor.blue, width: CGFloat = 1.0) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
    }
    
    func underline(color: UIColor = UIColor.lightGray, width: CGFloat = 1.0) {
        
        let border = CALayer()
        border.borderColor = color.cgColor
        border.frame = CGRect(x:0, y:self.frame.size.height - width, width:self.frame.size.width, height:self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func rightSeparator(color: UIColor = UIColor.lightGray, width: CGFloat = 0.5) {
        
        let border = CALayer()
        border.borderColor = color.cgColor
        border.frame = CGRect(x:self.frame.size.width - width, y:0, width:self.frame.size.width, height:self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
}










