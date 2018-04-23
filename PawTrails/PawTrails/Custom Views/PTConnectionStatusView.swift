//
//  PTConnectionStatusView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 01/02/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit


class PTConnectionStatusView: UIView {
    
    fileprivate static let noDataColor = UIColor.gray
    fileprivate static let noConnectionColor = UIColor.red
    fileprivate static let connectionColor = UIColor.green
    
    let dotImageView = UIView(frame: CGRect(x: 0, y:0, width: 20, height: 20))
    let statusLabel = UILabel(frame: CGRect(x: 0, y:0, width: 20, height: 20))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        
        dotImageView.backgroundColor = PTConnectionStatusView.noDataColor
        self.addSubview(dotImageView)
        
        statusLabel.text = ""
        statusLabel.font = UIFont.systemFont(ofSize: 8)
        self.addSubview(statusLabel)
        
        dotImageView.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(10)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalTo(statusLabel.snp.left).offset(-4)
        }
        
        statusLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(dotImageView)
            make.right.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dotImageView.layer.cornerRadius = dotImageView.frame.size.width/2.0
    }
    
    func setStatus(_ status: Int16, animated: Bool = true) {
        
        let dotColor = (status == 0) ? PTConnectionStatusView.noConnectionColor : PTConnectionStatusView.connectionColor
        let statusText = (status == 0) ? "OFFLINE" : "ONLINE"
        
        dotImageView.backgroundColor = dotColor
        statusLabel.text = statusText
    }
    
}
