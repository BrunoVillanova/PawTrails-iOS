                                                                                                                                                                                                                                                                                                                                  //
//  PhoneViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 17/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PhoneTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    
    fileprivate var selectedCC:CountryCode!
    
    fileprivate var index: Int = 0
    fileprivate let picker = UIPickerView()
    
    var parentEditor:EditUserProfilePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            numberTextField.textContentType = UITextContentType.telephoneNumber
        }

        tableView.tableFooterView = UIView()

        picker.delegate = self
        picker.dataSource = self
        self.codeTextField.inputView = picker
        self.codeTextField.delegate = self
        
        index = parentEditor.getCurrentCountryCodeIndex()
        if let number = parentEditor.user.phone?.number, let code = parentEditor.user.phone?.countryCode {
            codeTextField.text = code
            numberTextField.text = number
            index = parentEditor.getCountryCodeIndex(countryCode: code)
        }else{
            codeTextField.text = parentEditor.CountryCodes[index].code
        }
        selectedCC = parentEditor.CountryCodes[index]

        numberTextField.becomeFirstResponder()
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem?) {
        parentEditor.set(phone: numberTextField.text, selectedCC.code)
        parentEditor.refresh()
        view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.index = row
        self.codeTextField.text = parentEditor.CountryCodes[row].code
        self.selectedCC = parentEditor.CountryCodes[row]
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return parentEditor.CountryCodes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(parentEditor.CountryCodes[row].name!) \(parentEditor.CountryCodes[row].code!)"
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.codeTextField {
            picker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.numberTextField {
            saveAction(nil)
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
        self.tableView.endEditing(true)
    }

}
