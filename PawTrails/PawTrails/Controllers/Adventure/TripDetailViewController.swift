//
//  TripDetailViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 19/02/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit

protocol TripDetailViewControllerDelegate {
    func closed(viewController: TripDetailViewController)
}

class TripDetailViewController: UIViewController {

    var trip: Trip?
    var pet:Pet?
    var trips: [Trip]?
    let mapView = PTMapView(frame: CGRect.zero)
    let infoViewContainer = UIView(frame: .zero)
    let infoView = PTTripInfoView(frame: CGRect.zero)
    var delegate: TripDetailViewControllerDelegate?
    
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
        
        if self.navigationController != nil && self.presentingViewController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close-1x-png"), style: .plain, target: self, action: #selector(closeButtonTapped))
            self.navigationItem.leftBarButtonItem?.tintColor = .darkGray
        }
        
        self.navigationItem.title = "Adventure Result"
    }
    
    func closeButtonTapped() {
        self.dismiss(animated: true, completion: {
            self.delegate?.closed(viewController: self)
        })
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
        infoViewContainer.dropShadow(color: .black, opacity: 0.1, offSet: CGSize(width: 0, height: -2), radius: 1, scale: true)
    }
    
    fileprivate func configureData() {
        
//        if isBetaDemo {
//
//            self.trip = Trip(1916)
//            self.trip?.id = 1916
//            self.trip?.pet = pet!
//            self.trip?.name = "311-1521542104"
//            self.trip?.status = 2
//            self.trip?.startTimestamp = 1521542104
//            self.trip?.startTimestamp = 1521542132
//            self.trip?.timestamp = nil
//            self.trip?.totalTime = 28
//            self.trip?.totalDistance = 233
//            self.trip?.averageSpeed = 5
//            self.trip?.maxSpeed = 5
//            self.trip?.steps = 3
//
//            //Points
////            var point1 = TripPoint([1521542104,"","", 0])
////            point1.timestamp = 1521542104
////            point1.point = nil
////            point1.status = TripPointStatus.started
//
//            var point2 = TripPoint([1521542114,51.87686,-8.47968])
//            point2.timestamp = 1521542114
//            let pt = Point()
//            pt.latitude = 51.876860000000001
//            pt.longitude = -8.478800000000001
//            point2.point = pt
//            point2.status = TripPointStatus.started
//
//            var point3 = TripPoint([1521542120,51.8771,-8.478809999999999])
//            point3.timestamp = 1521542120
//            let pt3 = Point()
//            pt3.latitude = 51.8771
//            pt3.longitude = -8.478809999999993
//            point3.point = pt3
//            point3.status = TripPointStatus.running
//
//            var point4 = TripPoint([1521542126,51.877870000000001,-8.4767100000000006])
//            point4.timestamp = 1521542126
//            let pt4 = Point()
//            pt4.latitude = 51.877870000000001
//            pt4.longitude = -8.4767100000000006
//            point4.point = pt4
//            point4.status = TripPointStatus.stopped
//
//            self.trip?.points = [point2,point3,point4]
//            self.trip?.deviceData = []
//
//        }
        
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
