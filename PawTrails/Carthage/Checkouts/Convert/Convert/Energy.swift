//
//  Energy.swift
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

public struct Energy: Convertible {

    public enum Unit: Double {
        case joule = 1.0
        case kilojoule = 1_000.0
        case gramcalorie = 4.184
        case kilocalorie = 4_184.0
        case watthour = 3_600.0
        case kilowattHour = 360_000_0.0
        case btu = 1_055.06
        case footPound = 1.355_82
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var joule: Energy {
        return Energy(value: self, unit: .joule)
    }

    public var kilojoule: Energy {
        return Energy(value: self, unit: .kilojoule)
    }

    public var gramcalorie: Energy {
        return Energy(value: self, unit: .gramcalorie)
    }

    public var kilocalorie: Energy {
        return Energy(value: self, unit: .kilocalorie)
    }

    public var watthour: Energy {
        return Energy(value: self, unit: .watthour)
    }

    public var kilowatthour: Energy {
        return Energy(value: self, unit: .kilowattHour)
    }

    public var btu: Energy {
        return Energy(value: self, unit: .btu)
    }

    public var footPound: Energy {
        return Energy(value: self, unit: .footPound)
    }

}

public extension CGFloat {

    public var joule: Energy {
        return Energy(value: Double(self), unit: .joule)
    }

    public var kilojoule: Energy {
        return Energy(value: Double(self), unit: .kilojoule)
    }

    public var gramcalorie: Energy {
        return Energy(value: Double(self), unit: .gramcalorie)
    }

    public var kilocalorie: Energy {
        return Energy(value: Double(self), unit: .kilocalorie)
    }

    public var watthour: Energy {
        return Energy(value: Double(self), unit: .watthour)
    }

    public var kilowatthour: Energy {
        return Energy(value: Double(self), unit: .kilowattHour)
    }

    public var btu: Energy {
        return Energy(value: Double(self), unit: .btu)
    }

    public var footPound: Energy {
        return Energy(value: Double(self), unit: .footPound)
    }

}
