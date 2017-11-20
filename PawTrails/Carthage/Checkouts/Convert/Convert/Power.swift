//
//  Power.swift
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

public struct Power: Convertible {

    public enum Unit: Double {
        case milliwatt = 0.001
        case watt = 1.0
        case kilowatt = 1_000.0
        case megawatt = 1_000_000.0
        case gigawatt = 1_000_000_000.0
        case horsepower = 745.699_871_582_270_2
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var milliwatt: Power {
        return Power(value: self, unit: .milliwatt)
    }

    public var watt: Power {
        return Power(value: self, unit: .watt)
    }

    public var kilowatt: Power {
        return Power(value: self, unit: .kilowatt)
    }

    public var megawatt: Power {
        return Power(value: self, unit: .megawatt)
    }

    public var gigawatt: Power {
        return Power(value: self, unit: .gigawatt)
    }

    public var horsepower: Power {
        return Power(value: self, unit: .horsepower)
    }

}

public extension CGFloat {

    public var milliwatt: Power {
        return Power(value: Double(self), unit: .milliwatt)
    }

    public var watt: Power {
        return Power(value: Double(self), unit: .watt)
    }

    public var kilowatt: Power {
        return Power(value: Double(self), unit: .kilowatt)
    }

    public var megawatt: Power {
        return Power(value: Double(self), unit: .megawatt)
    }

    public var gigawatt: Power {
        return Power(value: Double(self), unit: .gigawatt)
    }

    public var horsepower: Power {
        return Power(value: Double(self), unit: .horsepower)
    }

}
