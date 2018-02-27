//
//  TripView.swift
//  PawTrails
//
//  Created by Marc Perello on 06/09/2017.
//  Modified by Bruno Villanova on 02/19/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PTTripInfoView: UIView {
    
    @IBOutlet weak var petProfilePic: PTBalloonImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        let nib = Bundle.main.loadNibNamed("PTTripInfoView", owner: self, options: nil)
        
        if let contentView = nib?.first as? UIView {
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }
    
    func configure(_ trip: Trip) {
        
        if let petName = trip.pet.name {
            self.petNameLabel.text = petName
        }
        
        if let imageUrl = trip.pet.imageURL {
            self.petProfilePic.imageUrl = imageUrl
        }
        
        
        // Set defaults
        var tripTotalDistanceText = "0 km"
        var tripAverageSpeedText = "0 bpm"
        var tripCurrentSpeed = "0 km/h"
        var tripTotalTime = "00:00:00"
        
        
        if let totalDistanceInMeters = trip.totalDistance {
            let totalDistanceInKm = Double(totalDistanceInMeters)/1000.0
            tripTotalDistanceText = String(format:"%0.2f km", totalDistanceInKm)
        }
        
        if let averageSpeed = trip.steps {
            tripAverageSpeedText = String(format:"%2i bpm", averageSpeed)
        }
        
        if let currentSpeed = trip.averageSpeed {
            tripCurrentSpeed = String(format:"%.2f km/h", currentSpeed)
        }
        
        if let totalTimestamp = trip.totalTime {
            tripTotalTime = totalTimestamp.timeStampToTimeString()
        }
        
        self.totalDistanceLabel.text = tripTotalDistanceText
        self.averageSpeedLabel.text = tripAverageSpeedText
        self.currentSpeedLabel.text = tripCurrentSpeed
        self.totalTimeLabel.text = tripTotalTime
    }
}
