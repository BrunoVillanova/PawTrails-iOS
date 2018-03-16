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
    var trips: [Trip]?
    let mapView = PTMapView(frame: CGRect.zero)
    let infoViewContainer = UIView(frame: .zero)
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
        
        infoViewContainer.backgroundColor = .white
        self.view.addSubview(infoViewContainer)
        infoViewContainer.addSubview(infoView)
        
        infoViewContainer.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottomMargin)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(170)
        }
        
        infoView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(infoViewContainer.snp.top)
        }
    }
    
    override func viewDidLayoutSubviews() {
        infoViewContainer.dropShadow(color: .black, opacity: 0.3, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
    }
    
    fileprivate func configureData() {
        if let trip = trip {
            mapView.setStaticTripView(trip)
            mapView.allowUserInteraction(true)
            infoView.configure(trip)
            
            if let petName = trip.pet.name {
                self.navigationItem.title = "\(petName)'s Adventure"
            }
        }
    }
}
