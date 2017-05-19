//
//  ViewExtensions.swift
//  PawTrails
//
//  Created by Marc Perello on 29/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

// MARK:- View

enum notificationType {
    
    case red, blue, green
    
    var color: UIColor {
        switch self {
        case .red: return UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 1.0)
        case .green: return UIColor(red: 0, green: 0.5, blue: 0.2, alpha: 1.0)
        default: return UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1.0)
        }
    }
}

extension UIViewController {
    
    func popUp(title:String, msg:String, actionTitle: String = "Ok", handler: ((UIAlertAction)->Void)? = nil){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        self.present(alert, animated: true, completion: nil)
    }
    
    func popUpDestructive(title:String, msg:String, cancelHandler: ((UIAlertAction)->Void)?, proceedHandler: ((UIAlertAction)->Void)?){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))
        alert.addAction(UIAlertAction(title: "Proceed", style: .destructive, handler: proceedHandler))
        self.present(alert, animated: true, completion: nil)
    }
    
    func popUp(title:String, msg:String, cancelHandler: ((UIAlertAction)->Void)?, proceedHandler: ((UIAlertAction)->Void)?){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))
        alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: proceedHandler))
        self.present(alert, animated: true, completion: nil)
    }
    
    func popUpUserLocationDenied(){
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: "Warning, location is not allowed", message: "Please enable it in Settings app under Privacy, Location Services.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (alert: UIAlertAction!) in
                UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
            }))
            self.present(alert, animated: true, completion: nil)
        })

    }
    
    func setTopBar(color: UIColor = UIColor.orange()) {
        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 20))
        topBar.backgroundColor = color.withAlphaComponent(0.8)
        view.addSubview(topBar)
    }
    
    func alert(title:String, msg:String, type: notificationType = .red){
        self.showNotification(title: msg, type: type)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
            self.hideNotification()
        }
    }
    
    // Alert for Image Picker
    
    func alert(_ imagePicker:UIImagePickerController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { (photo) in
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Choose from Gallery", style: .default, handler: { (galery) in
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func dismissAction(sender: UIButton?){
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissBarAction(sender: UIBarButtonItem?){
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func popAction(sender: UIBarButtonItem?){
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
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
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        
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

extension UINavigationController {
    
    func popTo<T>(viewController: T, handler: ((_ viewController:T)->())? = nil) {
        
        for element in viewControllers as Array {
            if element.isKind(of: T.self as! AnyClass) {
                if let handler = handler {
                    handler(element as! T)
                    self.popToViewController(element, animated: true)
                }
                break
            }
        }
    }
}

extension UIImage {
    
    public var encoded: Data? {
        var compression: CGFloat = 1.0
        var data: Data?
        repeat {
            data = UIImageJPEGRepresentation(self, compression)!
            compression -= 0.1
        } while data != nil && data!.count > Constants.maxImageSize  && compression >= 0
        return data
    }
    
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
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

extension UIImageView {
    
    func setupLayout(isPetOwner: Bool){
        self.circle()
        self.backgroundColor = UIColor.white
        let color: UIColor = isPetOwner ? .orange() : .darkGray
        self.border(color: color, width: 2.0)
    }

}

extension UICollectionView {
    
    func reloadAnimated() {
        let range = Range(uncheckedBounds: (0, self.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        self.reloadSections(indexSet)
    }

}
