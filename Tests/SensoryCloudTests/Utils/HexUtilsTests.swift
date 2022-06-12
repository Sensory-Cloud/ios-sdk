//
//  HexUtilsTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/11/22.
//

import XCTest
@testable import SensoryCloud

private struct TestCase {
    var str: String
    var dat: Data
    var bytes: [UInt8]
}

private var testCases: [TestCase] = [
    TestCase(str: "00", dat: Data([0]), bytes: [0]),
    TestCase(str: "00ff", dat: Data([0, 255]), bytes: [0, 255]),
    TestCase(
        str: "0123456789abcdef",
        dat: Data([1, 35, 69, 103, 137, 171, 205, 239]),
        bytes: [1, 35, 69, 103, 137, 171, 205, 239]
    ),
    TestCase(str: "0fa9", dat: Data([15, 169]), bytes: [15, 169])
]

class HexUtilsTests: XCTestCase {

    func testHexData() {
        for testCase in testCases {
            XCTAssertEqual(testCase.str.hexData, testCase.dat)
        }
        XCTAssertEqual("bogus".hexData, Data())
        XCTAssertEqual("00f".hexData, Data([0, 15]))
        XCTAssertEqual("FF".hexData, Data([255]))
    }

    func testHexBytes() {
        for testCase in testCases {
            XCTAssertEqual(testCase.str.hexBytes, testCase.bytes)
        }
        XCTAssertEqual("bogus".hexBytes, [UInt8]())
    }

    func testToHexString() {
        for testCase in testCases {
            XCTAssertEqual(testCase.dat.toHexString(), testCase.str)
        }
    }
}
