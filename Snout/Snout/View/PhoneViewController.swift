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
    var phone:Phone? = nil
    
    fileprivate var codes = [CountryCode]()
    fileprivate var selectedCC:CountryCode!
    
    var parentEditor:EditProfileTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
    }
    
    deinit {
        self.presenter.deteachView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if selectedCC != nil && self.numberTextField.text != nil && self.numberTextField.text != "" {
            parentEditor.setPhone(self.numberTextField.text!, cc: selectedCC)
        }
    }
    
    @IBAction func removeAction(_ sender: UIButton) {
        parentEditor.setPhone("", cc: selectedCC)
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    // MARK: - PhoneView
    
    func loadCountryCodes(_ codes: [CountryCode]) {
        self.codes = codes
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        self.codeTextField.inputView = picker
        if let ccc = phone == nil ? self.presenter.getCurrentCountryCode() : phone?.country_code?.shortname {
            guard let index = codes.index(where: { (cc) -> Bool in   cc.shortname == ccc }) else {
                return
            }
            picker.selectRow(index, inComponent: 0, animated: true)
            self.countryLabel.text = codes[index].name
            self.codeTextField.text = codes[index].code
            self.selectedCC = codes[index]
        }
        self.numberTextField.text = phone?.number
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
