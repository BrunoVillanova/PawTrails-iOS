//
//  Pressure.swift
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

public struct Pressure: Convertible {

    public enum Unit: Double {
        case atmosphere = 101_325.0
        case bar = 1_000_000.0
        case pascal = 1.0
        case psi = 6_894.757
        case torr = 133.322_4
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var atmosphere: Pressure {
        return Pressure(value: self, unit: .atmosphere)
    }

    public var bar: Pressure {
        return Pressure(value: self, unit: .bar)
    }

    public var pascal: Pressure {
        return Pressure(value: self, unit: .pascal)
    }

    public var psi: Pressure {
        return Pressure(value: self, unit: .psi)
    }

    public var torr: Pressure {
        return Pressure(value: self, unit: .torr)
    }

}

public extension CGFloat {

    public var atmosphere: Pressure {
        return Pressure(value: Double(self), unit: .atmosphere)
    }

    public var bar: Pressure {
        return Pressure(value: Double(self), unit: .bar)
    }

    public var pascal: Pressure {
        return Pressure(value: Double(self), unit: .pascal)
    }

    public var psi: Pressure {
        return Pressure(value: Double(self), unit: .psi)
    }

    public var torr: Pressure {
        return Pressure(value: Double(self), unit: .torr)
    }

}
