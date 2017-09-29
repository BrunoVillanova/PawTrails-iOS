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

enum subviewId: Int {
    case notification = 1, loading, activity
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
    
    func setTopBar(color: UIColor = UIColor.primary, alpha: CGFloat = 0.8) {
        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 20))
        topBar.tag = 102
        topBar.backgroundColor = color.withAlphaComponent(alpha)
        view.addSubview(topBar)
    }
    
    func removeTopBar(){
        if let topBar = view.subviews.first(where: { $0.tag == 102}) {
            topBar.removeFromSuperview()
        }
    }
    
    func alert(title:String, msg:String, type: notificationType = .red, disableTime: Int = 3, handler: (()->())? = nil){
        self.hideLoadingView(animated:false)
        self.showNotification(title: msg, type: type)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(disableTime)) {
            self.hideNotification()
            if let handler = handler { handler() }
        }
    }
    
    func alertwithGeature(title:String, msg:String, type: notificationType = .red, disableTime: Int = 3, geatureReconginzer: UITapGestureRecognizer, handler: (()->())? = nil){
        self.hideLoadingView(animated:false)
        self.showNotificationWithGesture(title: msg, type: type, geaturseRecognizer: geatureReconginzer)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(disableTime)) {
            self.hideNotification()
            if let handler = handler { handler() }
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
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissBarAction(sender: UIBarButtonItem?){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func popAction(sender: UIBarButtonItem?){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Connection Notifier
    
    func hideNotification() {

        if let notificationViews = UIApplication.shared.keyWindow?.subviews.filter({ $0.tag == subviewId.notification.rawValue }) {
            for notificationView in notificationViews {
                DispatchQueue.main.async {
                    notificationView.removeFromSuperview()
                }
            }
        }
    }
    
    func showNotification(title:String, type:notificationType = .blue) {
        
        let viewHeight:CGFloat = 30
        let yOffset:CGFloat = UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.height ?? 0.0)
        let viewFrame = CGRect(x: 0.0, y: yOffset, width: self.view.bounds.width, height: viewHeight)
        
        let notificationView = UIView(frame: viewFrame)
        notificationView.backgroundColor = type.color
        notificationView.tag = subviewId.notification.rawValue
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: viewHeight))
        label.text = title
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        
        notificationView.addSubview(label)
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(notificationView)
        }
        
        
    }
    
    
    func showNotificationWithGesture(title:String, type:notificationType = .blue, geaturseRecognizer: UITapGestureRecognizer) {
        
        
        let viewHeight:CGFloat = 30
        let yOffset:CGFloat = UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.height ?? 0.0)
        let viewFrame = CGRect(x: 0.0, y: yOffset, width: self.view.bounds.width, height: viewHeight)
        
        let notificationView = UIView(frame: viewFrame)
        notificationView.backgroundColor = type.color
        notificationView.tag = subviewId.notification.rawValue
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: viewHeight))
        label.text = title
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        
        notificationView.addSubview(label)
        
        notificationView.addGestureRecognizer(geaturseRecognizer)

        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(notificationView)
        }

        
    }
    
    
    // Loading View
    
    func showLoadingView() {
        
        let loadingView = UIVisualEffectView(frame: UIScreen.main.bounds)
        loadingView.effect = UIBlurEffect(style: .extraLight)
        loadingView.tag = subviewId.loading.rawValue
        
        let activity = UIActivityIndicatorView(frame: view.bounds)
        activity.activityIndicatorViewStyle = .whiteLarge
        activity.startAnimating()
        activity.tag = subviewId.activity.rawValue
        
        loadingView.contentView.addSubview(activity)
        
        loadingView.effect = nil
        activity.alpha = 0.0
        
        UIApplication.shared.keyWindow?.addSubview(loadingView)
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.6) {
                loadingView.effect = UIBlurEffect(style: .extraLight)
                activity.alpha = 1.0
            }
        }
    }
    
    func hideLoadingView(animated: Bool = true) {
        
        
        
        if let loadingView = UIApplication.shared.keyWindow?.subviews.first(where: { $0.tag == subviewId.loading.rawValue }) as? UIVisualEffectView {
            
            if let activity = loadingView.subviews.first(where: { $0.tag == subviewId.activity.rawValue }) as? UIActivityIndicatorView {
                DispatchQueue.main.async {
                    if animated {
                    UIView.animate(withDuration: 0.4, animations: {
                        loadingView.effect = nil
                        activity.alpha = 0.0
                    }, completion: { (success) in
                        if success {
                            loadingView.removeFromSuperview()
                        }
                    })
                    }else{
                        loadingView.effect = nil
                        activity.alpha = 0.0
                        loadingView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func hideLoadingView(with success:Bool){
        
        let label = UILabel(frame: view.bounds)
        label.text = "✓"
        label.font = UIFont.systemFont(ofSize: 70)
        label.textAlignment = .center
        label.textColor = UIColor.primary
        
        
        if let loadingView = view.subviews.first(where: { $0.tag == subviewId.loading.rawValue }) as? UIVisualEffectView {
            
            if let activity = loadingView.subviews.first(where: { $0.tag == subviewId.activity.rawValue }) as? UIActivityIndicatorView {
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
    
    public static var primary: UIColor {
        return UIColor(red: 206.0/255.0, green: 19.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    }
    
    public static var secondary: UIColor {
        return UIColor.white
    }

    public static func blueSystem() -> UIColor {
        return UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    }
    
}


  // Mohamed - Set a placeholder color for textviews.


extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
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
    
    
  
    func fullyroundedCorner(radius: CGFloat = 20) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    // choose which corner do you want to make round.
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        let rect = self.bounds
        mask.frame = rect
        mask.path = path.cgPath
        self.layer.mask = mask
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
    
    
    func biggerBorder(color: UIColor = UIColor.primary, width: CGFloat = 3.0) {
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
    
    func shadow(color:UIColor = UIColor.darkGray) {
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        layer.shadowOpacity = 0.5
        layer.shadowPath = shadowPath.cgPath
        
    }
}

extension UIImageView {
    
    func setupLayout(isPetOwner: Bool){
        self.circle()
        self.backgroundColor = UIColor.white
        let color: UIColor = isPetOwner ? .primary : .darkGray
        self.border(color: color, width: 2.0)
    }
}

extension CGRect {
    
    init(center: CGPoint, topCenter: CGPoint) {
        let side = center.distance(to: topCenter)
        self.init(x: Double(center.x) - side, y: Double(center.y) - side, width: side*2.0, height: side*2.0)
    }
    
}

extension UITableView {
    
    func reload(section: Int, with animation: UITableViewRowAnimation) {
        let indexSet = IndexSet(integer: section)
        self.reloadSections(indexSet, with: animation)
    }
    
}

extension UICollectionView {
    
    func reloadAnimated() {
        let range = Range(uncheckedBounds: (0, self.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        self.reloadSections(indexSet)
    }
    
}
