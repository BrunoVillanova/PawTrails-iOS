//
//  TripInfoCollectionViewCell.swift
//  PawTrails
//
//  Created by Bruno Villanova on 20/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit

class TripInfoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TripInfoCollectionViewCell"
    let infoView = PTTripInfoView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    
    fileprivate func initialize() {
        configureLayout()
    }
    
    fileprivate func configureLayout() {
        self.contentView.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func configureWithTrip(_ trip: Trip) {
        infoView.configure(trip)
    }
}
