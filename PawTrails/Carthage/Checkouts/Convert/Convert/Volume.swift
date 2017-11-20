//
//  Volume.swift
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

public struct Volume: Convertible {

    public enum Unit: Double {
        case microliter = 0.000_001
        case milliliter = 0.001
        case centiliter = 0.01
        case liter = 1.0
        case dekaliter = 10.0
        case hectoliter = 100.0
        case kiloliter = 1_000.0
        case gill = 0.118_294_118_250_000_01
        case gallon = 3.785_411_784_000_000_3
        case cup = 0.236_588_236_500_000_02
        case pint = 0.473_176_473_000_000_04
        case quart = 0.946_352_946_000_000_1
        case fluidOunce = 0.029_573_529_562_500_003
        case teaspoon = 0.004_928_921_595
        case tablespoon = 0.014_786_764_782_5
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var microliter: Volume {
        return Volume(value: self, unit: .microliter)
    }

    public var milliliter: Volume {
        return Volume(value: self, unit: .milliliter)
    }

    public var centiliter: Volume {
        return Volume(value: self, unit: .centiliter)
    }

    public var liter: Volume {
        return Volume(value: self, unit: .liter)
    }

    public var dekaliter: Volume {
        return Volume(value: self, unit: .dekaliter)
    }

    public var hectoliter: Volume {
        return Volume(value: self, unit: .hectoliter)
    }

    public var kiloliter: Volume {
        return Volume(value: self, unit: .kiloliter)
    }

    public var gill: Volume {
        return Volume(value: self, unit: .gill)
    }

    public var gallon: Volume {
        return Volume(value: self, unit: .gallon)
    }

    public var cup: Volume {
        return Volume(value: self, unit: .cup)
    }

    public var pint: Volume {
        return Volume(value: self, unit: .pint)
    }

    public var quart: Volume {
        return Volume(value: self, unit: .quart)
    }

    public var fluidOunce: Volume {
        return Volume(value: self, unit: .fluidOunce)
    }

    public var teaspoon: Volume {
        return Volume(value: self, unit: .teaspoon)
    }

    public var tablespoon: Volume {
        return Volume(value: self, unit: .tablespoon)
    }

}

public extension CGFloat {

    public var microliter: Volume {
        return Volume(value: Double(self), unit: .microliter)
    }

    public var milliliter: Volume {
        return Volume(value: Double(self), unit: .milliliter)
    }

    public var centiliter: Volume {
        return Volume(value: Double(self), unit: .centiliter)
    }

    public var liter: Volume {
        return Volume(value: Double(self), unit: .liter)
    }

    public var dekaliter: Volume {
        return Volume(value: Double(self), unit: .dekaliter)
    }

    public var hectoliter: Volume {
        return Volume(value: Double(self), unit: .hectoliter)
    }

    public var kiloliter: Volume {
        return Volume(value: Double(self), unit: .kiloliter)
    }

    public var gill: Volume {
        return Volume(value: Double(self), unit: .gill)
    }

    public var gallon: Volume {
        return Volume(value: Double(self), unit: .gallon)
    }

    public var cup: Volume {
        return Volume(value: Double(self), unit: .cup)
    }

    public var pint: Volume {
        return Volume(value: Double(self), unit: .pint)
    }

    public var quart: Volume {
        return Volume(value: Double(self), unit: .quart)
    }

    public var fluidOunce: Volume {
        return Volume(value: Double(self), unit: .fluidOunce)
    }

    public var teaspoon: Volume {
        return Volume(value: Double(self), unit: .teaspoon)
    }

    public var tablespoon: Volume {
        return Volume(value: Double(self), unit: .tablespoon)
    }

}
