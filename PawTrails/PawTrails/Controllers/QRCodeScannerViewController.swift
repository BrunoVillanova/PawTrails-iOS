//
//  QRCodeScannerViewController.swift
//  PawTrails
//
//  Created by Bruno on 19/01/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import swiftScan
import AVFoundation

public protocol QRCodeScannerViewControllerDelegate {
    func scanFinished(qrCodeScannerViewController: UIViewController, scanResult: String, error: String?)
}

class QRCodeScannerViewController: LBXScanViewController {

    var delegate: QRCodeScannerViewControllerDelegate?
    var topTitle:UILabel?
    var isOpenedFlash:Bool = false
    var bottomItemsView:UIView?
    var btnPhoto:UIButton = UIButton()
    var btnFlash:UIButton = UIButton()
    var btnMyQR:UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawBottomItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        if let scanResult = arrayResult[0].strScanned {
            delegate?.scanFinished(qrCodeScannerViewController: self, scanResult: scanResult, error: nil)
        }
    }
    
    fileprivate func initialize() {
        
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = [.all]
//        configureNavigatonBar()
        
        var style = LBXScanViewStyle()
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
        self.scanStyle = style
        
        setNeedCodeImage(needCodeImg: true)
        scanStyle?.centerUpOffset += 10
    }
    
//    fileprivate func configureNavigatonBar() {
//        // Transparent navigation bar
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
//        self.navigationController?.navigationBar.tintColor = UIColor.white
//        self.navigationController?.navigationBar.topItem?.title = " "
//        self.navigationController?.navigationBar.backItem?.title = " "
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
//    }

    static func authorizeCameraWith(completion:@escaping (Bool) -> Void ) {
        
        let granted = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo);
        
        switch granted {
            case AVAuthorizationStatus.authorized:
                completion(true)
                break;
            case AVAuthorizationStatus.denied:
                goToSystemPrivacySettings()
                completion(false)
                break;
            case AVAuthorizationStatus.restricted:
                goToSystemPrivacySettings()
                completion(false)
                break;
            case AVAuthorizationStatus.notDetermined:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted:Bool) in
                    if (!granted) {
                        goToSystemPrivacySettings()
                    }
                    completion(granted)
                })
        }
    }
    
    fileprivate static func goToSystemPrivacySettings() {
        if let appSetting = URL(string:UIApplicationOpenSettingsURLString) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(appSetting, options: [:], completionHandler: nil)
            } else{
                UIApplication.shared.openURL(appSetting)
            }
        }
    }
    
    
    func drawBottomItems()
    {
        if (bottomItemsView != nil) {
            
            return;
        }
        
        let yMax = self.view.frame.maxY - self.view.frame.minY
        
        bottomItemsView = UIView(frame:CGRect(x: 0.0, y: yMax-100,width: self.view.frame.size.width, height: 100 ) )
        
        
        bottomItemsView!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        
        self.view .addSubview(bottomItemsView!)
        
        
        let size = CGSize(width: 65, height: 87);
        
        self.btnFlash = UIButton()
        btnFlash.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        btnFlash.center = CGPoint(x: bottomItemsView!.frame.width/2, y: bottomItemsView!.frame.height/2)
        btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), for:UIControlState.normal)
        btnFlash.addTarget(self, action: #selector(QRCodeScannerViewController.openOrCloseFlash), for: UIControlEvents.touchUpInside)
        
        
//        self.btnPhoto = UIButton()
//        btnPhoto.bounds = btnFlash.bounds
//        btnPhoto.center = CGPoint(x: bottomItemsView!.frame.width/4, y: bottomItemsView!.frame.height/2)
//        btnPhoto.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_photo_nor"), for: UIControlState.normal)
//        btnPhoto.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_photo_down"), for: UIControlState.highlighted)
//        //        btnPhoto.addTarget(self, action: Selector(("openPhotoAlbum")), for: UIControlEvents.touchUpInside)
//
//        btnPhoto.addTarget(self, action: #selector(QQScanViewController.openLocalPhotoAlbum), for: UIControlEvents.touchUpInside)
//
//
//        self.btnMyQR = UIButton()
//        btnMyQR.bounds = btnFlash.bounds;
//        btnMyQR.center = CGPoint(x: bottomItemsView!.frame.width * 3/4, y: bottomItemsView!.frame.height/2);
//        btnMyQR.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_myqrcode_nor"), for: UIControlState.normal)
//        btnMyQR.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_myqrcode_down"), for: UIControlState.highlighted)
//        btnMyQR.addTarget(self, action: #selector(QQScanViewController.myCode), for: UIControlEvents.touchUpInside)
        
        bottomItemsView?.addSubview(btnFlash)
//        bottomItemsView?.addSubview(btnPhoto)
//        bottomItemsView?.addSubview(btnMyQR)
        
        self.view .addSubview(bottomItemsView!)
        
    }
    
    @objc func openOrCloseFlash()
    {
        scanObj?.changeTorch();
        
        isOpenedFlash = !isOpenedFlash
        
        if isOpenedFlash
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_down"), for:UIControlState.normal)
        }
        else
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), for:UIControlState.normal)
        }
    }

}
