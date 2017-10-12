//
//  PieChart.swift
//  PawTrails
//
//  Created by Marc Perello on 11/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import Foundation

class CircleChart: UIView {
    
    let percentLabel = UILabel()
    let circlee = CAShapeLayer()
    
    var percent: CGFloat = 0.0
    override init(frame: CGRect) {
        super.init(frame: frame)
        combinedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        combinedInit()
    }
    
    
    func combinedInit() {
        backgroundColor = UIColor.white
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        let x = NSLayoutConstraint(item: percentLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let w = NSLayoutConstraint(item: percentLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0)
        let y = NSLayoutConstraint(item: percentLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        percentLabel.adjustsFontSizeToFitWidth = true
        percentLabel.font = UIFont.systemFont(ofSize: 25)
        percentLabel.textColor = UIColor.darkGray
        percentLabel.textAlignment = .center
        percentLabel.adjustsFontSizeToFitWidth = true
        addSubview(percentLabel)
        NSLayoutConstraint.activate([w,x,y])
        
        circlee.strokeColor = UIColor(red: 0, green: 1.0, blue: 0.5, alpha: 1.0).cgColor
        circlee.fillColor = UIColor.clear.cgColor
        circlee.lineCap = kCALineCapRound
        layer.addSublayer(circlee)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        circlee.lineWidth = 0.08 * self.bounds.width
        circlee.frame = bounds
        super.layoutSublayers(of: layer)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.setLineWidth(0.08 * rect.width)
        context.setStrokeColor(UIColor.lightGray.cgColor)
        
        let innerRect = rect.insetBy(dx: 0.04 * rect.width, dy: 0.04 * rect.height)
        context.strokeEllipse(in: innerRect)
        context.restoreGState()
        
    }
    
    func setChart(at p: CGFloat, color: UIColor) {

        percent = p
        
        circlee.strokeColor = color.cgColor
        percentLabel.textColor = color

        percentLabel.text = "\(percent * 100) mins"

        if p == 0 {
            circlee.path = nil
        } else {
            let circlePath = CGMutablePath()
            
            let radians: CGFloat = 2 * .pi * p
            
            circlePath.addRelativeArc(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: 0.46 * bounds.width, startAngle: -.pi/2, delta: -radians)
            
            
            let trace = CABasicAnimation(keyPath: "strokeEnd")
            trace.fromValue = 0
            trace.toValue = 1
            trace.duration = 0.5
            circlee.add(trace, forKey: nil)
            circlee.path = circlePath
        }
    }
    
}
