//
//  Area.swift
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

public struct Area: Convertible {

    public enum Unit: Double {
        case squareInch = 0.000_645_16
        case squareFoot = 0.092_903_04
        case squareYard = 0.836_127_36
        case squareMeter = 1.0
        case squareKilometer = 1_000_000.0
        case squareMile = 2_589_988.110_336
        case acre = 4_046.873
        case hectare = 10_000.0
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var squareFoot: Area {
        return Area(value: self, unit: .squareFoot)
    }

    public var squareYard: Area {
        return Area(value: self, unit: .squareYard)
    }

    public var squareMeter: Area {
        return Area(value: self, unit: .squareMeter)
    }

    public var squareKilometer: Area {
        return Area(value: self, unit: .squareKilometer)
    }

    public var squareMile: Area {
        return Area(value: self, unit: .squareMile)
    }

    public var acre: Area {
        return Area(value: self, unit: .acre)
    }

    public var hectare: Area {
        return Area(value: self, unit: .hectare)
    }

}

public extension CGFloat {

    public var squareFoot: Area {
        return Area(value: Double(self), unit: .squareFoot)
    }

    public var squareYard: Area {
        return Area(value: Double(self), unit: .squareYard)
    }

    public var squareMeter: Area {
        return Area(value: Double(self), unit: .squareMeter)
    }

    public var squareKilometer: Area {
        return Area(value: Double(self), unit: .squareKilometer)
    }

    public var squareMile: Area {
        return Area(value: Double(self), unit: .squareMile)
    }

    public var acre: Area {
        return Area(value: Double(self), unit: .acre)
    }

    public var hectare: Area {
        return Area(value: Double(self), unit: .hectare)
    }

}
