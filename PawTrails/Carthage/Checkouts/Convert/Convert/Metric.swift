//
//  Metric.swift
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

public struct Metric: Convertible {

    public enum Unit: Double {
        case nano = 0.000_000_001
        case micro = 0.000_001
        case milli = 0.001
        case centi = 0.01
        case deci = 0.1
        case base = 1.0
        case deka = 10.0
        case hecto = 100.0
        case kilo = 1_000.0
        case mega = 1_000_000.0
        case giga = 1_000_000_000.0
        case tera = 1_000_000_000_000.0
        case peta = 1_000_000_000_000_000.0
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var nano: Metric {
        return Metric(value: self, unit: .nano)
    }

    public var micro: Metric {
        return Metric(value: self, unit: .micro)
    }

    public var milli: Metric {
        return Metric(value: self, unit: .milli)
    }

    public var centi: Metric {
        return Metric(value: self, unit: .centi)
    }

    public var deci: Metric {
        return Metric(value: self, unit: .deci)
    }

    public var base: Metric {
        return Metric(value: self, unit: .base)
    }

    public var deka: Metric {
        return Metric(value: self, unit: .deka)
    }

    public var hecto: Metric {
        return Metric(value: self, unit: .hecto)
    }

    public var kilo: Metric {
        return Metric(value: self, unit: .kilo)
    }

    public var mega: Metric {
        return Metric(value: self, unit: .mega)
    }

    public var giga: Metric {
        return Metric(value: self, unit: .giga)
    }

    public var tera: Metric {
        return Metric(value: self, unit: .tera)
    }

    public var peta: Metric {
        return Metric(value: self, unit: .peta)
    }

}

public extension CGFloat {

    public var nano: Metric {
        return Metric(value: Double(self), unit: .nano)
    }

    public var micro: Metric {
        return Metric(value: Double(self), unit: .micro)
    }

    public var milli: Metric {
        return Metric(value: Double(self), unit: .milli)
    }

    public var centi: Metric {
        return Metric(value: Double(self), unit: .centi)
    }

    public var deci: Metric {
        return Metric(value: Double(self), unit: .deci)
    }

    public var base: Metric {
        return Metric(value: Double(self), unit: .base)
    }

    public var deka: Metric {
        return Metric(value: Double(self), unit: .deka)
    }

    public var hecto: Metric {
        return Metric(value: Double(self), unit: .hecto)
    }

    public var kilo: Metric {
        return Metric(value: Double(self), unit: .kilo)
    }

    public var mega: Metric {
        return Metric(value: Double(self), unit: .mega)
    }

    public var giga: Metric {
        return Metric(value: Double(self), unit: .giga)
    }

    public var tera: Metric {
        return Metric(value: Double(self), unit: .tera)
    }

    public var peta: Metric {
        return Metric(value: Double(self), unit: .peta)
    }

}
