//
//  AddPetDeviceTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 12/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class AddPetDeviceTableViewController: UITableViewController, DeviceCodeView {

    @IBOutlet weak var deviceCodeTextField: UITextField!
    
    fileprivate let presenter = DeviceCodePresenter()
    fileprivate var isDeviceIdle = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
    }
    
    deinit {
        presenter.deteachView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if deviceCodeTextField.text != nil {
//            deviceCodeTextField.becomeFirstResponder()
//        }
    }

    // MARK: - DeviceCodeView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func codeFormat() {
        deviceCodeTextField.shake()
    }
    
    func wrongCode() {
        alert(title: "Error", msg: "Wrong Code")
    }
    
    func idle(_ code: String) {
        isDeviceIdle = true
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditPetDetailsTableViewController") as? AddEditPetDetailsTableViewController {
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
    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "addPetDetails" {
            presenter.check(deviceCodeTextField.text)
            return isDeviceIdle
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is AddEditPetDetailsTableViewController {
            self.view.endEditing(true)
            (segue.destination as! AddEditPetDetailsTableViewController).deviceCode = deviceCodeTextField.text!
        }
    }
}
