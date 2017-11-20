//
//  Length.swift
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

public struct Length: Convertible {

    public enum Unit: Double {
        case millimeter = 0.001
        case centimeter = 0.01
        case decimeter = 0.1
        case meter = 1.0
        case dekameter = 10.0
        case hectometer = 100.0
        case kilometer = 1_000.0
        case yard = 0.914_4
        case parsec = 30_856_775_813_060_000.0
        case mile = 1_609.344
        case foot = 0.304_8
        case fathom = 1.828_8
        case inch = 0.025_4
        case league = 4_000.0
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var millimeter: Length {
        return Length(value: self, unit: .millimeter)
    }

    public var centimeter: Length {
        return Length(value: self, unit: .centimeter)
    }

    public var decimeter: Length {
        return Length(value: self, unit: .decimeter)
    }

    public var meter: Length {
        return Length(value: self, unit: .meter)
    }

    public var dekameter: Length {
        return Length(value: self, unit: .dekameter)
    }

    public var hectometer: Length {
        return Length(value: self, unit: .hectometer)
    }

    public var kilometer: Length {
        return Length(value: self, unit: .kilometer)
    }

    public var yard: Length {
        return Length(value: self, unit: .yard)
    }

    public var parsec: Length {
        return Length(value: self, unit: .parsec)
    }

    public var mile: Length {
        return Length(value: self, unit: .mile)
    }

    public var foot: Length {
        return Length(value: self, unit: .foot)
    }

    public var fathom: Length {
        return Length(value: self, unit: .fathom)
    }

    public var inch: Length {
        return Length(value: self, unit: .inch)
    }

    public var league: Length {
        return Length(value: self, unit: .league)
    }

}

public extension CGFloat {

    public var millimeter: Length {
        return Length(value: Double(self), unit: .millimeter)
    }

    public var centimeter: Length {
        return Length(value: Double(self), unit: .centimeter)
    }

    public var decimeter: Length {
        return Length(value: Double(self), unit: .decimeter)
    }

    public var meter: Length {
        return Length(value: Double(self), unit: .meter)
    }

    public var dekameter: Length {
        return Length(value: Double(self), unit: .dekameter)
    }

    public var hectometer: Length {
        return Length(value: Double(self), unit: .hectometer)
    }

    public var kilometer: Length {
        return Length(value: Double(self), unit: .kilometer)
    }

    public var yard: Length {
        return Length(value: Double(self), unit: .yard)
    }

    public var parsec: Length {
        return Length(value: Double(self), unit: .parsec)
    }

    public var mile: Length {
        return Length(value: Double(self), unit: .mile)
    }

    public var foot: Length {
        return Length(value: Double(self), unit: .foot)
    }

    public var fathom: Length {
        return Length(value: Double(self), unit: .fathom)
    }

    public var inch: Length {
        return Length(value: Double(self), unit: .inch)
    }

    public var league: Length {
        return Length(value: Double(self), unit: .league)
    }

}
