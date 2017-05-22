//
//  ScanQRViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 24/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import AVFoundation

class ScanQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, DeviceCodeView {

    var isAddDevice:Bool! = true
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    fileprivate var captureSession:AVCaptureSession?
    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var qrCodeFrameView: UIView?
    
    fileprivate let presenter = DeviceCodePresenter()
    
    fileprivate var isCheckingCode: Bool = false
    fileprivate var attempts: Int = 0

    var petId:Int16 = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        setupSession()
        setupPreview()
        startSession()
    }
    
    deinit {
        presenter.deteachView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopSession()
    }
    
    // MARK: - DeviceCodeView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func codeFormat() {
        alert(title: "Erro", msg: "Code Format")
    }
    
    func wrongCode() {
        attempts += 1
        if attempts <= 3 {
            isCheckingCode = false
        }else{
            stopSession()
            popUp(title: "Warning", msg: "The code is not correct", actionTitle: "Dismiss", handler: { (dismiss) in
                self.attempts = 0
                self.isCheckingCode = false
                self.startSession()
            })
        }
    }
    func codeChanged() {
        dismissAction(sender: nil)
    }

    func idle(_ code: String) {
        stopSession()
        if petId != -1 {
            presenter.change(code, to: petId)
        }else if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditPetDetailsTableViewController") as? AddEditPetDetailsTableViewController {
            vc.deviceCode = code
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Connection Notifications
    
    func connectedToNetwork() {
        hideNotification()
    }
    
    func notConnectedToNetwork() {
        showNotification(title: Message.Instance.connectionError(type: .NoConnection), type: .red)
    }


    // MARK: - Camera

    func setupSession() {

        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
        } catch {
            print(error)
        }
    }
    
    func setupPreview() {

        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Video preview
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = cameraView.layer.bounds
        cameraView.layer.addSublayer(videoPreviewLayer!)
    }
    
    func addSquareAroundQRCode() {
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.blue.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            cameraView.addSubview(qrCodeFrameView)
            cameraView.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    func removeSquareAroundQRCode() {
        qrCodeFrameView?.removeFromSuperview()
    }
    
    func startSession() {
        
        guard let session = captureSession else { return }
        
        if !session.isRunning {
            videoQueue().async {
                session.startRunning()
                DispatchQueue.main.async {
                    self.loadingActivityIndicator.stopAnimating()
                    self.addSquareAroundQRCode()
                }
            }
        }
    }
    
    func stopSession() {
        guard let session = captureSession else { return }
        
        if session.isRunning {
            videoQueue().async {
                session.stopRunning()
                DispatchQueue.main.async {
                    self.removeSquareAroundQRCode()
                }
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.global(qos: .default)
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {

            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if !isCheckingCode, let code = metadataObj.stringValue {
                isCheckingCode = true
                presenter.check(code)
            }
        }
    }

}
