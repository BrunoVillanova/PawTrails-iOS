//
//  PTCustomButton.swift
//  PawTrails
//
//  Created by Abhijith on 29/03/2018.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit


/*
 
 DESCRIPTION : To create different types of button such as round rect, squared, Image etc..
 
HOW TO USE
**********
 
 1) using Interface Builder :
    --> Add a UIButton and change it's classs to PTCustomButton
    --> Change properties as required.
 
 2) using Code :
 
    *** Style - .Image ***
    let imageButton : PTCustomButton = PTCustomButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100), style: .Image);
    imageButton.setImage(UIImage(named:"bgCheckmark"), for: .normal)
    self.view.addSubview(imageButton)
 
    **** Style - .RoundRect ***
    let button = PTCustomButton(frame: CGRect(x: 100, y: 100, width: 100, height: 45), style: .RoundRect)
    button.customBGColor = UIColor.init(red: 0, green: 155/255, blue: 222/255, alpha: 1) // OPTIONAL
    button.setTitleColor(.blue, for: .normal) // OPTIONAL
    button.cornerRadius = 15
    button.setTitle("Click", for: .normal)
    self.view.addSubview(button)
 
*/


// Default color values
let defaultButtonColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
let defaultButtonTitleColor = UIColor(red:45/255, green: 45/255, blue: 45/255, alpha: 1)

@IBDesignable class PTButton: UIButton {

    
    enum Style: String {
        case RoundRect = "rectangle"
        case Square = "triangle"
        case Circle = "circle"
        case Image = "image"
    }

    var style = Style.RoundRect // default shape

    // Stored property which will only be accessible in IB
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'shape' instead.")
    @IBInspectable var shapeName: String? {
        willSet {
            // Ensure user enters a valid shape while making it lowercase.
            // Ignore input if not valid.
            if let newStyle = Style(rawValue: newValue?.lowercased() ?? "") {
                style = newStyle
            }
        }
    }
    
    //MARK: IB Methods
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            refreshCR(_value: cornerRadius)
        }
    }
    
    @IBInspectable var customBGColor: UIColor = defaultButtonColor {
        didSet {
            refreshBGColor(_color: customBGColor)
        }
    }
    
    @IBInspectable var customTextColor: UIColor = defaultButtonTitleColor {
        didSet {
            refreshTitleColor(_color: customTextColor)
        }
    }
    
    //MARK: Init Methods
    
    required init?(coder aDecoder: NSCoder) {
        print("init?(coder:)")
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        sharedInit()
    }
    
    init(frame: CGRect,style:Style) {
        self.style = style
        super.init(frame: frame);
        sharedInit()
        configureButton(withStyle: style)
        
    }
    
    override func prepareForInterfaceBuilder() {
        print("prepareForInterfaceBuilder()")
        sharedInit()
    }
    
    func sharedInit() {
        refreshCR(_value: cornerRadius)
        refreshBGColor(_color: customBGColor)
    }
    
    
    //MARK: Private Methods
    
    private func refreshCR(_value: CGFloat) {
        layer.cornerRadius = _value
    }
    
    private func refreshTitleColor(_color: UIColor) {
        //self.setTitleColor(customTextColor, for: .normal)
        self.tintColor = customTextColor
    }
    
    private func configureButton(withStyle style:Style) {
        
        switch style {
        case .RoundRect:
            self.circle()
        case .Circle:
            debugPrint("Circle")
        case .Square:
            self.cornerRadius = 0
        case .Image:
            self.setBackgroundImage(nil, for: .normal)
            self.backgroundColor = .clear
            self.setTitle("", for: .normal)
        }
    }
    
    private func refreshBGColor(_color: UIColor) {
        
        let size: CGSize = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        _color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let bgImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        setBackgroundImage(bgImage, for: UIControlState.normal)
        clipsToBounds = true
        
    }
}

