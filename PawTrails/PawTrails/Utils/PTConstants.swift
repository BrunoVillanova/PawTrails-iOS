//
//  Constants.swift
//  PawTrails
//
//  Created by Bruno Villanova on 10/12/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

struct PTConstants {
    struct keys {
        // MARK: HockeyApp
        #if RELEASE
        static let hockeyAppAppId = "b6cbb680d9d94b1ea6932091f7d517e0"
        #elseif BETA
        static let hockeyAppAppId = "fa1ebcdeb5484a2ea10e15c780fdd138"
        #endif
    }
    struct colors {
        static let primary = UIColor(red: 212/255, green: 20/255, blue: 61/255, alpha: 1)
        static let lightGray = UIColor(white: 0, alpha: 0.1)
        static let darkGray = UIColor(red: 65/255, green: 72/255, blue: 82/255, alpha: 1)
    }
}

