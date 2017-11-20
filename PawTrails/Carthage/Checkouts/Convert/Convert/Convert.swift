//
//  Convert.swift
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

public protocol Convertible: Comparable, Hashable {

    associatedtype Unit: RawRepresentable

    var value: Double { get }
    var unit: Unit { get }

    init(value: Double, unit: Unit)

    func to(_ unit: Unit) -> Self

    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static func / (lhs: Self, rhs: Self) -> Self

}

public extension Convertible where Unit.RawValue: Hashable {

    var hashValue: Int {
        return value.hashValue ^ unit.rawValue.hashValue
    }

}

public extension Convertible where Unit.RawValue == Double {

    func to(_ unit: Unit) -> Self {
        let value = self.value * self.unit.rawValue / unit.rawValue
        return Self(value: value, unit: unit)
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        return perform(lhs: lhs, rhs: rhs, operation: +)
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        return perform(lhs: lhs, rhs: rhs, operation: -)
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        return perform(lhs: lhs, rhs: rhs, operation: *)
    }

    public static func / (lhs: Self, rhs: Self) -> Self {
        guard rhs.value != 0.0 else { fatalError("Attempting to divide by zero.") }
        return perform(lhs: lhs, rhs: rhs, operation: /)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        let (lhs, rhs, _) = computeCommonUnitValues(lhs, rhs)
        return lhs < rhs
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        let (lhs, rhs, _) = computeCommonUnitValues(lhs, rhs)
        return lhs == rhs
    }

    // MARK: Private

    private static func perform(lhs: Self, rhs: Self, operation: (Double, Double) -> Double) -> Self {
        let (lhs, rhs, unit) = computeCommonUnitValues(lhs, rhs)
        let value = operation(lhs, rhs)
        return Self(value: value, unit: unit)
    }

    private static func computeCommonUnitValues(_ lhs: Self, _ rhs: Self) -> (lhs: Double, rhs: Double, unit: Unit) {
        return lhs.unit.rawValue < rhs.unit.rawValue
            ? (lhs: lhs.value, rhs: rhs.to(lhs.unit).value, unit: lhs.unit)
            : (lhs: lhs.to(rhs.unit).value, rhs: rhs.value, unit: rhs.unit)
    }

}
