//
//  TripDetailViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 19/02/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit

class TripDetailViewController: UIViewController {

    var trip: Trip?
    let mapView = PTMapView(frame: CGRect.zero)
    let infoView = PTTripInfoView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
        configureLayout()
        configureData()
    }
    
    fileprivate func configureLayout() {
        self.extendedLayoutIncludesOpaqueBars = false
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(mapView)
        self.view.addSubview(infoView)
        
        infoView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottomMargin)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(infoView.snp.top)
        }
    }
    
    fileprivate func configureData() {
        if let trip = trip {
            mapView.setStaticTripView(trip)
            infoView.configure(trip)
            
            if let petName = trip.pet.name {
                self.navigationItem.title = "\(petName)'s Adventure"
            }
        }
    }
}
