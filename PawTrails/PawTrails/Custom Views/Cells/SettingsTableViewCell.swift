//
//  SettingsTableViewCell.swift
//  PawTrails
//
//  Created by Bruno Villanova on 20/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    static let reuseIdentifier = "SettingsTableViewCell"
    var mainView: UIView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
         setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    fileprivate func setupView() {
        
        if let viewFromNib = Bundle.main.loadNibNamed("SettingsTableViewCell", owner: self, options: nil)?.first as? UIView {
            viewFromNib.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewFromNib.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            mainView = viewFromNib
            self.addSubview(viewFromNib)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
    }
}
