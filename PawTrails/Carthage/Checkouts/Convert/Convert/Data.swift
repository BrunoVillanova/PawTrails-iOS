//
//  Data.swift
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

public struct Data: Convertible {

    public enum Unit: Double {
        case bit = 0.000_001
        case byte = 0.000_008
        case kilobit = 0.001
        case kilobyte = 0.008
        case megabit = 1.0
        case megabyte = 8.0
        case gigabit = 1_000.0
        case gigabyte = 8_000.0
        case terabit = 1_000_000.0
        case terabyte = 8_000_000.0
        case petabit = 1_000_000_000.0
        case petabyte = 8_000_000_000.0
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var bit: Data {
        return Data(value: self, unit: .bit)
    }

    public var byte: Data {
        return Data(value: self, unit: .byte)
    }

    public var kilobit: Data {
        return Data(value: self, unit: .kilobit)
    }

    public var kilobyte: Data {
        return Data(value: self, unit: .kilobyte)
    }

    public var megabit: Data {
        return Data(value: self, unit: .megabit)
    }

    public var megabyte: Data {
        return Data(value: self, unit: .megabyte)
    }

    public var gigabit: Data {
        return Data(value: self, unit: .gigabit)
    }

    public var gigabyte: Data {
        return Data(value: self, unit: .gigabyte)
    }

    public var terabit: Data {
        return Data(value: self, unit: .terabit)
    }

    public var terabyte: Data {
        return Data(value: self, unit: .terabyte)
    }

    public var petabit: Data {
        return Data(value: self, unit: .petabit)
    }

    public var petabyte: Data {
        return Data(value: self, unit: .petabyte)
    }
    
}

public extension CGFloat {

    public var bit: Data {
        return Data(value: Double(self), unit: .bit)
    }

    public var byte: Data {
        return Data(value: Double(self), unit: .byte)
    }

    public var kilobit: Data {
        return Data(value: Double(self), unit: .kilobit)
    }

    public var kilobyte: Data {
        return Data(value: Double(self), unit: .kilobyte)
    }

    public var megabit: Data {
        return Data(value: Double(self), unit: .megabit)
    }

    public var megabyte: Data {
        return Data(value: Double(self), unit: .megabyte)
    }

    public var gigabit: Data {
        return Data(value: Double(self), unit: .gigabit)
    }

    public var gigabyte: Data {
        return Data(value: Double(self), unit: .gigabyte)
    }

    public var terabit: Data {
        return Data(value: Double(self), unit: .terabit)
    }

    public var terabyte: Data {
        return Data(value: Double(self), unit: .terabyte)
    }

    public var petabit: Data {
        return Data(value: Double(self), unit: .petabit)
    }

    public var petabyte: Data {
        return Data(value: Double(self), unit: .petabyte)
    }
    
}
