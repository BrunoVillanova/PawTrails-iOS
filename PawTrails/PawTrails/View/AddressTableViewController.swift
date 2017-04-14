//
//  AddressViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 20/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class AddressTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var firstLineTextField: UITextField!
    @IBOutlet weak var secondLineTextField: UITextField!
    @IBOutlet weak var thirdLineTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
   
    fileprivate var selectedCC:CountryCode?
    
    var parentEditor:EditUserProfilePresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

        cityTextField.rightSeparator()
        postalCodeTextField.rightSeparator()
        
        if #available(iOS 10.0, *) {
            firstLineTextField.textContentType = UITextContentType.streetAddressLine1
            secondLineTextField.textContentType = UITextContentType.streetAddressLine2
            cityTextField.textContentType = UITextContentType.addressCity
            postalCodeTextField.textContentType = UITextContentType.postalCode
            stateTextField.textContentType = UITextContentType.addressState
        }
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        self.countryTextField.inputView = picker
        
        if let address = parentEditor.getAddress() {
            firstLineTextField.text = address.line0
            secondLineTextField.text = address.line1
            thirdLineTextField.text = address.line2
            cityTextField.text = address.city
            postalCodeTextField.text = address.postal_code
            stateTextField.text = address.state
            countryTextField.text = address.country
            
            if address.country != nil && address.country != "" {
                
                let index = parentEditor.getCountryCodeIndex(countryShortName: address.country!)
                picker.selectRow(index, inComponent: 0, animated: true)
                self.countryTextField.text = parentEditor.CountryCodes[index].name! + ", " + parentEditor.CountryCodes[index].shortname!
                self.selectedCC = parentEditor.CountryCodes[index]
                
            }
        }

    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem?) {
        
        var address = _Address()
        address.line0 = firstLineTextField.text
        address.line1 = secondLineTextField.text
        address.line2 = thirdLineTextField.text
        address.city = cityTextField.text
        address.postal_code = postalCodeTextField.text
        address.state = stateTextField.text
        address.country = (selectedCC?.shortname != nil && self.countryTextField.text != nil && countryTextField.text != "") ? selectedCC?.shortname : nil
        
        self.parentEditor.set(address: address)
        parentEditor.refresh()
        view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }

    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.countryTextField.text = parentEditor.CountryCodes[row].name! + ", " + parentEditor.CountryCodes[row].shortname!
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
        return parentEditor.CountryCodes[row].name!
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case firstLineTextField: secondLineTextField.becomeFirstResponder()
            break
        case secondLineTextField: thirdLineTextField.becomeFirstResponder()
            break
        case thirdLineTextField: cityTextField.becomeFirstResponder()
            break
        case cityTextField: stateTextField.becomeFirstResponder()
            break
        case stateTextField: postalCodeTextField.becomeFirstResponder()
            break
        case postalCodeTextField: countryTextField.becomeFirstResponder()
            break
        case countryTextField: saveAction(nil)
            break
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
}
