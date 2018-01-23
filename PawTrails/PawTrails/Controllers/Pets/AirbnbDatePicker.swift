//
//  AirbnbDatePicker.swift
//  airbnb-datepicker
//
//  Created by Yonas Stephen on 22/2/17.
//  Copyright © 2017 Yonas Stephen. All rights reserved.
//

import UIKit

public class AirbnbDatePicker: UIView, AirbnbDatePickerDelegate {
    
    public var selectedStartDate: Date?
    public var selectedEndDate: Date?
    public var delegate: UIViewController?
    
    var dateFormatter: DateFormatter {
        get {
            let f = DateFormatter()
            f.dateFormat = "d MMM"
            return f
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var dateInputButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.primary
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(AirbnbDatePicker.showDatePicker), for: .touchUpInside)
        let img = UIImage(named: "Calendar", in: Bundle(for: AirbnbDatePicker.self), compatibleWith: nil)
        btn.setImage(img, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd - MMMM"
        let result = formatter.string(from: date)
        btn.setTitle(result, for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        
        
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        btn.titleLabel?.lineBreakMode = .byTruncatingTail
        return btn
    }()
    
    func setupViews() {
        addSubview(dateInputButton)
        
        dateInputButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dateInputButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        dateInputButton.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        dateInputButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func showDatePicker() {
        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: selectedStartDate, dateTo: selectedEndDate)
        datePickerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: datePickerViewController)

        delegate?.present(navigationController, animated: true, completion: nil)
        
        
    }
    
    
    
    public func datePickerController(_ datePickerController: AirbnbDatePickerViewController, didSaveStartDate startDate: Date?, endDate: Date?) {
        selectedStartDate = startDate
        selectedEndDate = endDate
        
        if selectedStartDate == nil && selectedEndDate == nil {
            dateInputButton.setTitle("Anytime", for: .normal)
            
        } else {
            dateInputButton.setTitle("\(dateFormatter.string(from: startDate!)) - \(dateFormatter.string(from: endDate!))", for: .normal)
            print ("\(startDate!)")
        }
    }
}
