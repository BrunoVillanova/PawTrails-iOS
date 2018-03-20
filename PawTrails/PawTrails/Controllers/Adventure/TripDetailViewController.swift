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

    var trips: [Trip]?
    let mapView = PTMapView(frame: CGRect.zero)
    let infoViewContainer = UIView(frame: .zero)
    let infoView = PTTripInfoView(frame: CGRect.zero)
    var delegate: TripDetailViewControllerDelegate?
    
    
    let shareButton = UIButton()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()

        
        // isBetaDemo
        //Share button
        //shareButton.frame = CGRect(x: self.view.frame.size.width - 60, y: 450, width: 50, height: 50)
        shareButton.setImage(UIImage(named:"ShareButton-1x-png"), for: .normal)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        self.view.addSubview(shareButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapShareButton() {
        
        shareToSocialMedia(message: "yo",link: "https://pawtrails.com")

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
        
        shareButton.frame = CGRect(x: self.view.frame.size.width - 75, y: mapView.frame.height-34, width: 75, height: 75)
    }
    
    
    
    fileprivate func configureData() {
        
        trips?.forEach({ (trip) in
            mapView.setStaticTripView(trip)
            mapView.allowUserInteraction(true)
            infoView.configure(trip)
            
            if let petName = trip.pet.name {
                self.navigationItem.title = "\(petName)'s Adventure"
            }
        })
    }
}
