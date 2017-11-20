//
//  ConvertSpec.swift
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
import Quick
import Nimble

@testable import Convert

class ConvertSpec: QuickSpec {

    override func spec() {

        describe("Mass") {

            describe("Conversion") {

                var result: Mass!

                context("converting to a greater unit") {

                    beforeEach {
                        result = 123.gram.to(.kilogram)
                    }

                    it("should be the correct value") {
                        let expected = 0.123.kilogram
                        expect(result).to(equal(expected))
                    }

                }

                context("converting to a smaller unit") {

                    beforeEach {
                        result = 1.456.kilogram.to(.gram)
                    }

                    it("should be the correct value") {
                        let expected = 1_456.gram
                        expect(result).to(equal(expected))
                    }

                }

                context("converting to the same unit") {

                    beforeEach {
                        result = 1234.gram.to(.gram)
                    }

                    it("should be the same value") {
                        let expected = 1234.gram
                        expect(result).to(equal(expected))
                    }

                }

                context("converting to another unit and back again") {

                    beforeEach {
                        result = 1.kilogram.to(.pound).to(.kilogram)
                    }

                    it("should be the same unit as the original") {
                        expect(result.unit).to(equal(Mass.Unit.kilogram))
                    }

                    it("should be one kilogram") {
                        expect(result.value).to(equal(1.0))
                    }

                }

            }

            describe("Arithmetic") {

                var left: Mass!
                var right: Mass!

                beforeEach {
                    left = 100.0.milligram
                    right = 400.0.milligram
                }

                it("should add correctly") {
                    let result = left + right
                    expect(result.value).to(equal(500.0))
                }

                it("should subtract correctly") {
                    let result = left - right
                    expect(result.value).to(equal(-300.0))
                }

                it("should multiply correctly") {
                    let result = left * right
                    expect(result.value).to(equal(40_000.0))
                }

                it("should divide correctly") {
                    let result = left / right
                    expect(result.value).to(equal(0.25))
                }

            }

            describe("Comparable") {

                var left: Mass!
                var right: Mass!

                context("When left is less than right") {

                    beforeEach {
                        left = 1.milligram
                        right = 2.milligram
                    }

                    it("should be less than") {
                        expect(left < right).to(beTrue())
                    }

                }

                context("When left is equal to right") {

                    beforeEach {
                        left = 1.milligram
                        right = 1.milligram
                    }

                    it("should not be less than") {
                        expect(left < right).toNot(beTrue())
                    }

                }

                context("When left is greater than right") {

                    beforeEach {
                        left = 2.milligram
                        right = 1.milligram
                    }

                    it("should not be less than") {
                        expect(left < right).toNot(beTrue())
                    }

                }

            }

            describe("Equatable") {

                var left: Mass!
                var right: Mass!

                context("When left is equal to right") {

                    beforeEach {
                        left = 100.milligram
                        right = 100.milligram
                    }

                    it("should be equal") {
                        expect(left == right).to(beTrue())
                    }

                }

                context("When left is equal to right with different units") {

                    beforeEach {
                        left = 1000.gram
                        right = 1.kilogram
                    }

                    it("should be equal") {
                        expect(left == right).to(beTrue())
                    }

                }

                context("When left is not equal to right") {

                    beforeEach {
                        left = 1.gram
                        right = 2.gram
                    }

                    it("should not be equal") {
                        expect(left == right).toNot(beTrue())
                    }

                }

            }

        }

    }

}
