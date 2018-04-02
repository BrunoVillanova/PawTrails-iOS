//
//  PTAlertViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 01/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit

typealias OkResult = (_ alertViewController: PTAlertViewController) -> Void
typealias CancelResult = (_ alertViewController: PTAlertViewController) -> Void

class PTAlertViewController: UIViewController {

    var infoLabel: UILabel? {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Montserrat", size: 15)
        label.textColor = PTConstants.colors.darkGray
        return label
    }
    let textField = UITextField(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let okButton = NiceButton(title: "OK")
    let cancelButton = NiceButton(title: "Cancel")
    var okResult: OkResult?
    var cancelResult: CancelResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialize()
    }
    
    convenience init (_ title: String?, infoText: String? = nil, textFieldLabelTitle: String?, okResult: OkResult?, cancelResult: CancelResult?) {
        self.init()
        modalPresentationStyle = .overCurrentContext
        titleLabel.text = title
        textField.placeholder = textFieldLabelTitle
        
        if let okResult = okResult {
            self.okResult = okResult
            okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        }
        
        if let cancelResult = cancelResult {
            self.cancelResult = cancelResult
            cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        }
        
        if let infoText = infoText {
            infoLabel?.text = infoText
        }
    }
    
    
    func okButtonTapped() {
        self.okResult?(self)
    }
    
    func cancelButtonTapped() {
        self.cancelResult?(self)
    }
    
    func dismiss() {
        self.dismiss(animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initialize() {
        
        view.backgroundColor = .clear
        view.isOpaque = false
        
        // Background View
        
        let backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = UIColor(red: 65/255, green: 72/255, blue: 82/255, alpha: 0.7)
        self.view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // AlertView
        let alertView = RoundedShadowView(frame: .zero)
        self.view.addSubview(alertView)
        
        alertView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(120)
            make.centerX.equalToSuperview()
        }
        // Alert View
        
        let alertContainerView = UIView(frame: .zero)
        alertContainerView.layer.cornerRadius = 10
        alertContainerView.clipsToBounds = true
        alertContainerView.layer.masksToBounds = true

        alertView.addSubview(alertContainerView)
        
        alertContainerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Title View
        
        let titleView = UIView(frame: .zero)
        alertContainerView.addSubview(titleView)
        
        titleView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        // Title View Background
        
        let titleViewBackgroundImageView = UIImageView(frame: .zero)
        let titleBarBackgroundImage = UIImage(named: "AlertViewTitleBarBackground")
        titleViewBackgroundImageView.image = titleBarBackgroundImage
        titleView.addSubview(titleViewBackgroundImageView)
        
        titleViewBackgroundImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(titleBarBackgroundImage!.size.height)
            make.width.equalTo(titleBarBackgroundImage!.size.width)
        }
        
        // Title View Title
        
        titleLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        // Content View
        
        let contentView = UIView(frame: .zero)
        contentView.backgroundColor = .white
        alertContainerView.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        
        // TODO: Add Label Before Text Field if needed
        
        
        // Text Field
        
        textField.font = UIFont(name: "Montserrat-Light", size: 14)
        textField.textColor = PTConstants.colors.darkGray
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.tintColor = PTConstants.colors.darkGray
        
        contentView.addSubview(textField)
        
        textField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(52)
        }
        
        // Buttons View
        let buttonsView = UIView(frame: .zero)
        buttonsView.backgroundColor = .white
        alertContainerView.addSubview(buttonsView)
        
        buttonsView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
        
        // Button Top SeparatorView
        let buttonsTopSeparatorView = UIView(frame: .zero)
        buttonsTopSeparatorView.backgroundColor = PTConstants.colors.newLightGray
        buttonsView.addSubview(buttonsTopSeparatorView)

        buttonsTopSeparatorView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }

        // Default cancel and ok buttons
        let verticalSeparatorWidth: CGFloat = 1
        let buttonSize: CGFloat = (titleBarBackgroundImage!.size.width)/2.0-verticalSeparatorWidth
        // Add buttons
        buttonsView.addSubview(cancelButton)

        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(buttonsTopSeparatorView.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(buttonSize)
        }

        
        buttonsView.addSubview(okButton)

        okButton.snp.makeConstraints { (make) in
            make.top.equalTo(cancelButton)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(cancelButton)
        }

        let buttonsVerticalSeparator = UIView(frame: .zero)
        buttonsVerticalSeparator.backgroundColor = PTConstants.colors.newLightGray
        buttonsView.addSubview(buttonsVerticalSeparator)

        buttonsVerticalSeparator.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(cancelButton.snp.right)
            make.right.equalTo(okButton.snp.left)
        }

    }
    

}

class RoundedShadowView: UIView {
    
    var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2
            
            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }
    
}

class NiceButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
    }
    
    fileprivate func commonInit () {
        titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 15)
        setTitleColor(PTConstants.colors.lightBlue, for: .normal)
    }
}
