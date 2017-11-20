//
//  Frequency.swift
//  Convert
//
//  Copyright © 2017 Daniel Byon
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import CoreGraphics

public struct Frequency: Convertible {

    public enum Unit: Double {
        case hertz = 1.0
        case kilohertz = 1_000.0
        case megahertz = 1_000_000.0
        case gigahertz = 1_000_000_000.0
        case degreesPerHour = 0.000_000_771_607_938_272
        case degreesPerMinute = 0.000_046_296_296_296_296
        case degreesPerSecond = 0.002_777_777_777_777_78
        case radiansPerHour = 0.000_044_209_706_414_415
        case radiansPerMinute = 0.002_652_582_384_864_92
        case radiansPerSecond = 0.159_154_943_091_895
        case revolutionsPerMinute = 0.016_666_666_666_666_666
        // revolutionsPerSecond is the same as hertz, but Swift requires enum raw values to be unique
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var hertz: Frequency {
        return Frequency(value: self, unit: .hertz)
    }

    public var kilohertz: Frequency {
        return Frequency(value: self, unit: .kilohertz)
    }

    public var megahertz: Frequency {
        return Frequency(value: self, unit: .megahertz)
    }

    public var gigahertz: Frequency {
        return Frequency(value: self, unit: .gigahertz)
    }

    public var degreesPerHour: Frequency {
        return Frequency(value: self, unit: .degreesPerHour)
    }

    public var degreesPerMinute: Frequency {
        return Frequency(value: self, unit: .degreesPerMinute)
    }

    public var degreesPerSecond: Frequency {
        return Frequency(value: self, unit: .degreesPerSecond)
    }

    public var radiansPerHour: Frequency {
        return Frequency(value: self, unit: .radiansPerHour)
    }

    public var radiansPerMinute: Frequency {
        return Frequency(value: self, unit: .radiansPerMinute)
    }

    public var radiansPerSecond: Frequency {
        return Frequency(value: self, unit: .radiansPerSecond)
    }

    public var revolutionsPerMinute: Frequency {
        return Frequency(value: self, unit: .revolutionsPerMinute)
    }

}

public extension CGFloat {

    public var hertz: Frequency {
        return Frequency(value: Double(self), unit: .hertz)
    }

    public var kilohertz: Frequency {
        return Frequency(value: Double(self), unit: .kilohertz)
    }

    public var megahertz: Frequency {
        return Frequency(value: Double(self), unit: .megahertz)
    }

    public var gigahertz: Frequency {
        return Frequency(value: Double(self), unit: .gigahertz)
    }

    public var degreesPerHour: Frequency {
        return Frequency(value: Double(self), unit: .degreesPerHour)
    }

    public var degreesPerMinute: Frequency {
        return Frequency(value: Double(self), unit: .degreesPerMinute)
    }

    public var degreesPerSecond: Frequency {
        return Frequency(value: Double(self), unit: .degreesPerSecond)
    }

    public var radiansPerHour: Frequency {
        return Frequency(value: Double(self), unit: .radiansPerHour)
    }

    public var radiansPerMinute: Frequency {
        return Frequency(value: Double(self), unit: .radiansPerMinute)
    }

    public var radiansPerSecond: Frequency {
        return Frequency(value: Double(self), unit: .radiansPerSecond)
    }

    public var revolutionsPerMinute: Frequency {
        return Frequency(value: Double(self), unit: .revolutionsPerMinute)
    }

}
