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
    
//    func alert(title:String, msg:String, actionTitle: String = "Ok"){
//        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
    
    func setTopBar(color: UIColor = UIColor.orange()) {
        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 20))
        topBar.backgroundColor = color
        view.addSubview(topBar)
    }
    
    func alert(title:String, msg:String){
        self.showNotification(title: msg, type: .red)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
            self.hideNotification()
        }
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
