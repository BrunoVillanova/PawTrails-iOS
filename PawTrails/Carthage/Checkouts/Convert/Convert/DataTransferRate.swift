//
//  DataTransferRate.swift
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

public struct DataTransferRate: Convertible {

    public enum Unit: Double {
        case bitPerSecond = 0.000_001
        case bytePerSecond = 0.000_008
        case kilobitPerSecond = 0.001
        case kilobytePerSecond = 0.008
        case megabitPerSecond = 1.0
        case megabytePerSecond = 8.0
        case gigabitPerSecond = 1_000.0
        case gigabytePerSecond = 8_000.0
        case terabitPerSecond = 1_000_000.0
        case terabytePerSecond = 8_000_000.0
        case petabitPerSecond = 1_000_000_000.0
        case petabytePerSecond = 8_000_000_000.0
    }

    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

}

public extension Double {

    public var bitPerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .bitPerSecond)
    }

    public var bytePerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .bytePerSecond)
    }

    public var kilobitPerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .kilobitPerSecond)
    }

    public var kilobytePerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .kilobytePerSecond)
    }

    public var megabitPerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .megabitPerSecond)
    }

    public var megabytePerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .megabytePerSecond)
    }

    public var gigabitPerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .gigabitPerSecond)
    }

    public var gigabytePerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .gigabytePerSecond)
    }

    public var terabitPerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .terabitPerSecond)
    }

    public var terabytePerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .terabytePerSecond)
    }

    public var petabitPerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .petabitPerSecond)
    }

    public var petabytePerSecond: DataTransferRate {
        return DataTransferRate(value: self, unit: .petabytePerSecond)
    }

}

public extension CGFloat {

    public var bitPerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .bitPerSecond)
    }

    public var bytePerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .bytePerSecond)
    }

    public var kilobitPerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .kilobitPerSecond)
    }

    public var kilobytePerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .kilobytePerSecond)
    }

    public var megabitPerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .megabitPerSecond)
    }

    public var megabytePerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .megabytePerSecond)
    }

    public var gigabitPerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .gigabitPerSecond)
    }

    public var gigabytePerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .gigabytePerSecond)
    }

    public var terabitPerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .terabitPerSecond)
    }

    public var terabytePerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .terabytePerSecond)
    }

    public var petabitPerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .petabitPerSecond)
    }

    public var petabytePerSecond: DataTransferRate {
        return DataTransferRate(value: Double(self), unit: .petabytePerSecond)
    }

}
