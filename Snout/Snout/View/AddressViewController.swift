//
//  AddressViewController.swift
//  Snout
//
//  Created by Marc Perello on 20/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class AddressViewController: UIViewController, AddressView, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var firstLineTextField: UITextField!
    @IBOutlet weak var secondLineTextField: UITextField!
    @IBOutlet weak var thirdLineTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
    fileprivate let presenter = AddressPresenter()
    
    fileprivate var codes = [CountryCode]()
    fileprivate var selectedCC:CountryCode?
    
    var parentEditor:EditProfileTableViewController!
    var address:Address? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
        self.firstLineTextField.becomeFirstResponder()
    }

    deinit {
        self.presenter.deteachView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if parentEditor != nil {
            var data = [String:String]()           
            data["line0"] = firstLineTextField.text ?? ""
            data["line1"] = secondLineTextField.text ?? ""
            data["line2"] = thirdLineTextField.text ?? ""
            data["city"] = cityTextField.text ?? ""
            data["postal_code"] = postalCodeTextField.text ?? ""
            data["state"] = stateTextField.text ?? ""
            data["country"] = (selectedCC?.shortname != nil && self.countryTextField.text != nil && countryTextField.text != "") ? selectedCC?.shortname : ""
            self.parentEditor.setAddress(data)
        }
    }
    
    // MARK: - AddressView

    func loadCountries(_ codes: [CountryCode]) {
        self.codes = codes
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        self.countryTextField.inputView = picker
        if address != nil {
            firstLineTextField.text = address?.line0
            secondLineTextField.text = address?.line1
            thirdLineTextField.text = address?.line2
            cityTextField.text = address?.city
            postalCodeTextField.text = address?.postal_code
            stateTextField.text = address?.state
            countryTextField.text = address?.country
            if address?.country != nil && address?.country != ""{
                if let index = self.codes.index(where: { $0.shortname == address?.country }) {
                    picker.selectRow(index, inComponent: 0, animated: true)
                    self.countryTextField.text = codes[index].name! + ", " + codes[index].shortname!
                    self.selectedCC = codes[index]
                }
            }else{
                NSLog("%@", address ?? "address is null")
            }
        }

    }
    
    func countriesNotFound() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func errorMessage(_ error: errorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.countryTextField.text = codes[row].name! + ", " + codes[row].shortname!
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
        return codes[row].name!
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
