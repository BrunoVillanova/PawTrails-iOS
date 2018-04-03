//
//  PTRulerSlider.swift
//  PawTrails
//
//  Created by Abhijith on 29/03/2018.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit


/*
 
 HOW TO USE
 **********
 
 1) Adopt protocol SliderDelegate
 
 2) Implement delegate methods :  func sliderDidScroll(value: Double)
        Use the 'value' to display the slider value in your controller.
 
 3) Use below code to add slider view.
 
    let ruler = PTRulerSlider(frame: CGRect(x: 0, y: 300, width: UIScreen.main.bounds.width, height: 24), scrollP:61,scrollQ:8600, scaleP: 0, scaleQ: 100)
    ruler.delegate = self
    self.view.addSubview(ruler)
 
 NOTE :
    scrollP : scroll start offset
    scrollQ : scroll content width
    scaleP & scaleQ : Weight range
 
    Adjust the scrollP value to change the default scroll position to match with indicator arrow.
    iphone 8 : 71.25
    iPhone 8 plus : 52
 
 */

protocol SliderDelegate: class {
    func sliderDidScroll(valueInKg:Double)
}

class PTRulerSlider: UIView, UIScrollViewDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var scrollP = 42.0 // Scrollview starting content offset. Usually it's 0.
    var scrollQ = 4000.0 // Scrollview content width
    
    //Output value range. [scaleP,scaleQ]
    var scaleP = 0
    var scaleQ = 50
    
    var scroll: UIScrollView!
    weak var delegate: SliderDelegate? // External delegate
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
    }
    
    init (frame:CGRect,scrollP:Double,scrollQ:Double,scaleP:Int,scaleQ:Int) {
        
        self.scrollQ = scrollQ
        self.scaleP  = scaleP
        self.scaleQ  = scaleQ
        self.scrollP = scrollP
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //MARK: Scrollview delegate methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let p = scaleDownNumber()
        delegate?.sliderDidScroll(valueInKg: p)
        
        if scroll.contentOffset.x < CGFloat(scrollP) {
            setDefaultScrollposition()
        }
        
    }
    
    //MARK: Private methods
    
    private func setDefaultScrollposition() {
        scroll.setContentOffset(CGPoint(x:scrollP,y:0), animated: false)
    }
    
    /*
     This methode scale down a number from One range to another : [a,b]-->[c,d]
     Formula : y = c + ((d-c)/(b-a))(x-a).
     Eg : [0,3600]--[0,50]
    */
    
    private func scaleDownNumber()-> Double {
    
        let scrollOffset = scroll.contentOffset.x
        let p = Double(scaleP) + (Double(scaleQ)/scrollQ)*Double((scrollOffset-CGFloat(scrollP)))
        //let p = 0 + (50/3600)*(scroll.contentOffset.x-0)
        return Double(p)
    
    }
    
    private func setup() {
        
        scroll = UIScrollView(frame: self.bounds)
        scroll.backgroundColor = UIColor(patternImage: UIImage(named: "Ruler")!)
        scroll.delegate = self // Internal delegate
        scroll.bounces = false
        scroll.contentSize = CGSize(width: CGFloat(scrollQ), height: self.frame.size.height)
        scroll.decelerationRate = UIScrollViewDecelerationRateFast
        scroll.showsHorizontalScrollIndicator = false
        self.addSubview(scroll)
        
        //Arrow image
        let image = UIImage(named:"scaleArrow")
        let imgView = UIImageView(image: image)
        let arrowWidth = 22.0
        let arrowHeight = 72.0
        imgView.frame = CGRect(x: Double((scroll.frame.size.width/2)) - (arrowWidth/2), y: -50, width: arrowWidth, height: arrowHeight)
        self.addSubview(imgView)
        
        self.backgroundColor = .clear
        setDefaultScrollposition()
    }

    


}
