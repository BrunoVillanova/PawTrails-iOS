//
//  PTUnitConversion.swift
//  PawTrails
//
//  Created by Abhijith on 03/04/2018.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class PTUnitConversion: NSObject {

    // KG to LBS
    class func KgToLBS(weight : Double)-> Double {
        
        let lbs = weight*2.2046226218488
        return lbs.rounded(toPlaces: 2)
    }
    
}
