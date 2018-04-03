//
//  PTAlertViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 01/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit

enum AlertTitleBarStyle {
    case green, red
    
    var backgroundImageName: String {
        switch self {
            case .green: return "AlertViewTitleBarBackgroundGreen"
            case .red: return "AlertViewTitleBarBackgroundRed"
        }
    }
}

enum AlertResultType {
    case ok, cancel
}

enum AlertButtontType: Int {
    case ok = 0, cancel = 1
    
    var title: String {
        switch self {
            case .ok: return "OK"
            case .cancel: return "Cancel"
        }
    }
    
    var resultType: AlertResultType {
        switch self {
            case .ok: return .ok
            case .cancel: return .cancel
        }
    }
}

typealias AlertResult = (_ alertViewController: PTAlertViewController, _ alertResult: AlertResultType) -> Void

class PTAlertViewController: UIViewController {

    var textField: UITextField?
    var infoLabel: UILabel?
    let titleLabel = UILabel(frame: .zero)
    var alertResult: AlertResult?
    let verticalSeparatorWidth: CGFloat = 1
    var maxButtonSize: CGFloat = UIScreen.main.bounds.size.width
    let buttonsView = UIView(frame: .zero)
    let buttonsTopSeparatorView = UIView(frame: .zero)
    var resultButtons = [UIButton]()
    var titleBarStyle = AlertTitleBarStyle.green
    var infoText: String?
    var textFieldLabelTitle: String?
    var textFieldText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialize()
    }
    
    convenience init (_ title: String?,
                      infoText: String? = nil,
            textFieldLabelTitle: String? = nil,
            buttonTypes: [AlertButtontType]? = [AlertButtontType.cancel, AlertButtontType.ok],
            titleBarStyle: AlertTitleBarStyle? = AlertTitleBarStyle.green,
            alertResult: AlertResult?) {
        
        self.init()
        modalPresentationStyle = .overCurrentContext
        titleLabel.text = title
        self.textFieldLabelTitle = textFieldLabelTitle
        self.infoText = infoText
        self.alertResult = alertResult
        self.titleBarStyle = titleBarStyle!
        
        if let buttonTypes = buttonTypes {
            configureButtons(buttonTypes)
        }
    }
    
    func buttonTapped(_ sender: UIButton) {
        if let resultType = AlertButtontType(rawValue: sender.tag)?.resultType {
            self.alertResult?(self, resultType)
        }
    }
    
    
    func dismiss() {
        self.dismiss(animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func configureButtons(_ buttonsTypes: [AlertButtontType]) {
        
        var buttons = [UIButton]()
        
        for buttonType in buttonsTypes {
            let button = NiceButton(title: buttonType.title)
            button.tag = buttonType.hashValue
            buttons.append(button)
        }
        
        resultButtons = buttons
    }
    
    fileprivate func configureButtons() {
        
        let buttons = resultButtons
        // Default cancel and ok buttons
        let buttonsCount: CGFloat = CGFloat(buttons.count)
        let buttonSize = (maxButtonSize/buttonsCount)-((buttonsCount-1.0)*verticalSeparatorWidth)
        
        for i in 0...buttons.count-1 {
            
            let button: UIButton = buttons[i]
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            
            // Add buttons
            buttonsView.addSubview(button)
            
            button.snp.makeConstraints { (make) in
                make.top.equalTo(buttonsTopSeparatorView.snp.bottom)
                make.bottom.equalToSuperview()
                
                if i == 0 {
                   make.left.equalToSuperview()
                } else if i == buttons.count-1 {
                    make.right.equalToSuperview()
                } else {
                    let lastSubview = buttonsView.subviews[buttonsView.subviews.count-2]
                    make.left.equalTo(lastSubview.snp.right)
                }
                
                make.width.equalTo(buttonSize)
            }
            
            if i < buttons.count-1 {
                let buttonsVerticalSeparator = UIView(frame: .zero)
                buttonsVerticalSeparator.backgroundColor = PTConstants.colors.newLightGray
                buttonsView.addSubview(buttonsVerticalSeparator)
                
                buttonsVerticalSeparator.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.left.equalTo(button.snp.right)
                    make.width.equalTo(verticalSeparatorWidth)
                }
            }
        }
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
        let titleBarBackgroundImage = UIImage(named: titleBarStyle.backgroundImageName)
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
        if let infoText = infoText {
            infoLabel = UILabel(frame: .zero)
            infoLabel!.text = infoText
            infoLabel!.numberOfLines = 0
            infoLabel!.font = UIFont(name: "Montserrat-Regular", size: 15)
            infoLabel!.textColor = PTConstants.colors.darkGray
            infoLabel!.textAlignment = .center
            
            contentView.addSubview(infoLabel!)
            
            infoLabel!.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(24)
                make.left.equalToSuperview().offset(24)
                make.right.equalToSuperview().offset(-24)
            }
        }
        
        // Text Field
        
        if let textFieldLabelTitle = textFieldLabelTitle {
            textField = UITextField(frame: .zero)
            textField!.font = UIFont(name: "Montserrat-Light", size: 14)
            textField!.textColor = PTConstants.colors.darkGray
            textField!.borderStyle = .roundedRect
            textField!.textAlignment = .center
            textField!.tintColor = PTConstants.colors.darkGray
            textField!.placeholder = textFieldLabelTitle
            textField!.text = textFieldText
            
            contentView.addSubview(textField!)
            
            textField!.snp.makeConstraints { (make) in
                
                if let infoLabel = infoLabel {
                    make.top.equalTo(infoLabel.snp.bottom).offset(16)
                } else {
                    make.top.equalToSuperview().offset(24)
                }

                make.left.equalToSuperview().offset(24)
                make.right.equalToSuperview().offset(-24)
                make.height.equalTo(52)
            }
        }
        
        if let textField = textField {
            textField.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-24)
            }
        } else if let infoLabel = infoLabel {
            infoLabel.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-24)
            }
        }
    
        // Buttons View
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
        buttonsTopSeparatorView.backgroundColor = PTConstants.colors.newLightGray
        buttonsView.addSubview(buttonsTopSeparatorView)

        buttonsTopSeparatorView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }


        maxButtonSize = titleBarBackgroundImage!.size.width
        
        configureButtons()
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
