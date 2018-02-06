//
//  AddPetDeviceTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 12/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class AddPetDeviceTableViewController: UITableViewController, UITextFieldDelegate, DeviceCodeView {

    @IBOutlet weak var deviceCodeTextField: UITextField!
    
    fileprivate let presenter = DeviceCodePresenter()
    fileprivate var isDeviceIdle = false
    var petId: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        if petId != -1 {
            navigationItem.rightBarButtonItem?.title = "Done"
            navigationItem.title = "Device"
        }
    }
    
    deinit {
        presenter.deteachView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isDeviceIdle = false
        if deviceCodeTextField.text != nil {
            deviceCodeTextField.becomeFirstResponder()
        }
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
    
    func codeChanged() {
        dismissAction(sender: nil)
    }
    
    func idle(_ code: String) {
        isDeviceIdle = true
        if petId != -1 {
            presenter.change(code, to: petId)
        }else if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditPetDetailsTableViewController") as? AddEditPetDetailsTableViewController {
            vc.deviceCode = code
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func donebtnPressed(_ sender: Any) {
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == deviceCodeTextField {
            presenter.check(textField.text)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if !isDeviceIdle && identifier == "addPetDetails" {
            presenter.check(deviceCodeTextField.text)
            return isDeviceIdle
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is AddEditPetDetailsTableViewController {
            self.view.endEditing(true)
            (segue.destination as! AddEditPetDetailsTableViewController).deviceCode = deviceCodeTextField.text!
        }else if segue.destination is ScanQRViewController {
            self.view.endEditing(true)
            (segue.destination as! ScanQRViewController).petId = self.petId
        }
    }
}
