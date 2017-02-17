//
//  PhoneViewController.swift
//  Snout
//
//  Created by Marc Perello on 17/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PhoneViewController: UIViewController, PhoneView, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    
    fileprivate let presenter = PhonePresenter()
    var codes = [CountryCode]()
    var parentEditor:EditProfileTableViewController!
    var selectedCC:CountryCode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
        if parentEditor.user.phone != nil {
            self.codeTextField.text = parentEditor.user.phone?.country_code?.code
            self.numberTextField.text = parentEditor.user.phone?.number
        }
        self.codeTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if selectedCC != nil && self.numberTextField.text != nil && self.numberTextField.text != "" {
            parentEditor.setPhone(self.numberTextField.text!, cc: selectedCC)
        }
    }
    
    // MARK: - PhoneView
    
    func loadCountryCodes(_ codes: [CountryCode]) {
        self.codes = codes
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        self.codeTextField.inputView = picker
    }
    
    func countryCodesNotFound() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func errorMessage(_ error: errorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.codeTextField.text = codes[row].code
        self.countryLabel.text = codes[row].name
        self.selectedCC = codes[row]
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return codes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(codes[row].name!) \(codes[row].code!)"
    }
    

}
