//
//  Clock.swift
//  PawTrails
//
//  Created by Marc Perello on 12/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class Clock {
    
    private var startTime: CFAbsoluteTime
    private var elapsedTime: CFAbsoluteTime
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
        elapsedTime = CFAbsoluteTimeGetCurrent()
    }
    
    func reset(){
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop(){
        elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
    }
    
    var elapsedSeconds:Double {
        return elapsedTime
    }
}
