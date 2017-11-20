//
//  Mass.swift
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

public struct Mass: Convertible {

    public enum Unit: Double {
        case milligram = 0.001
        case centigram = 0.01
        case decigram = 0.1
        case gram = 1.0
        case dekagram = 10.0
        case hectogram = 100.0
        case kilogram = 1_000.0
        case ton = 1_000_000.0
        case carat = 0.2
        case newton = 101.971_621_297_792_85
        case ounce = 28.349_523_125
        case pound = 453.592_37
        case stone = 6_350.293_18
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var milligram: Mass {
        return Mass(value: self, unit: .milligram)
    }

    public var centigram: Mass {
        return Mass(value: self, unit: .centigram)
    }

    public var decigram: Mass {
        return Mass(value: self, unit: .decigram)
    }

    public var gram: Mass {
        return Mass(value: self, unit: .gram)
    }

    public var dekagram: Mass {
        return Mass(value: self, unit: .dekagram)
    }

    public var hectogram: Mass {
        return Mass(value: self, unit: .hectogram)
    }

    public var kilogram: Mass {
        return Mass(value: self, unit: .kilogram)
    }

    public var ton: Mass {
        return Mass(value: self, unit: .ton)
    }

    public var carat: Mass {
        return Mass(value: self, unit: .carat)
    }

    public var newton: Mass {
        return Mass(value: self, unit: .newton)
    }

    public var ounce: Mass {
        return Mass(value: self, unit: .ounce)
    }

    public var pound: Mass {
        return Mass(value: self, unit: .pound)
    }

    public var stone: Mass {
        return Mass(value: self, unit: .stone)
    }
    
}

public extension CGFloat {

    public var milligram: Mass {
        return Mass(value: Double(self), unit: .milligram)
    }

    public var centigram: Mass {
        return Mass(value: Double(self), unit: .centigram)
    }

    public var decigram: Mass {
        return Mass(value: Double(self), unit: .decigram)
    }

    public var gram: Mass {
        return Mass(value: Double(self), unit: .gram)
    }

    public var dekagram: Mass {
        return Mass(value: Double(self), unit: .dekagram)
    }

    public var hectogram: Mass {
        return Mass(value: Double(self), unit: .hectogram)
    }

    public var kilogram: Mass {
        return Mass(value: Double(self), unit: .kilogram)
    }

    public var ton: Mass {
        return Mass(value: Double(self), unit: .ton)
    }

    public var carat: Mass {
        return Mass(value: Double(self), unit: .carat)
    }

    public var newton: Mass {
        return Mass(value: Double(self), unit: .newton)
    }

    public var ounce: Mass {
        return Mass(value: Double(self), unit: .ounce)
    }

    public var pound: Mass {
        return Mass(value: Double(self), unit: .pound)
    }

    public var stone: Mass {
        return Mass(value: Double(self), unit: .stone)
    }
    
}
