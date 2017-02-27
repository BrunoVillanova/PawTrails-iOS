//
//  AddChangeDeviceViewController.swift
//  Snout
//
//  Created by Marc Perello on 24/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import AVFoundation

class AddChangeDeviceViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var isAddDevice:Bool! = true
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var codeTextField: UITextField!
    
    fileprivate var captureSession:AVCaptureSession?
    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var qrCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !loadCamera() {
            codeTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Camera
    
    func loadCamera() -> Bool {
        
        if loadCameraInput() {
            loadCameraOutput()
            captureSession?.startRunning()
            addSquarAroudQRCode()
            return true
        }
        return false
    }
    
    func loadCameraInput() -> Bool {

        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {

            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    func loadCameraOutput() {

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
    
    func addSquarAroudQRCode() {
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.blue.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            cameraView.addSubview(qrCodeFrameView)
            cameraView.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
//            messageLabel.text = "No QR code is detected"
            print("No QR code is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
//                messageLabel.text = metadataObj.stringValue
                print(metadataObj.stringValue)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
