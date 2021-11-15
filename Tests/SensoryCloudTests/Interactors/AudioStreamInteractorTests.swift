//
//  AudioStreamInteractorTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/15/21.
//

import XCTest
@testable import SensoryCloud

final class AudioStreamInteractorTests: XCTestCase {

    func testRequirePermissions() throws {
        let audio = AudioStreamInteractor.shared
        let expectCallback = XCTestExpectation(description: "Callback should be called")

        audio.requestPermission { allowed, error in
            XCTAssertFalse(allowed, "Microphone permissions are not allowed while unit testing")
            XCTAssertNil(error, "No error, simply permissions denied")
            XCTAssertFalse(audio.configured, "Configuration should not be completed")
            expectCallback.fulfill()
        }

        wait(for: [expectCallback], timeout: 1)
    }
}
