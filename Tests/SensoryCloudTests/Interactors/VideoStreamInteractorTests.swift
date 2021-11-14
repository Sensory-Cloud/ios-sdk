//
//  VideoStreamInteractorTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/14/21.
//

import XCTest
@testable import SensoryCloud

final class VideoStreamInteractorTests: XCTestCase {
    
    func testRequestPermissions() throws {
        let video = VideoStreamInteractor.shared
        let expectCallback = XCTestExpectation(description: "Callback should be called")

        video.requestPermission { allowed, error in
            XCTAssert(allowed, "Camera permissions should be allowed")
            XCTAssertNotNil(error, "An error should occur during configuration since we're in a unit testing context")
            XCTAssertFalse(video.configured, "Configuration should have failed")
            expectCallback.fulfill()
        }

        wait(for: [expectCallback], timeout: 1)
    }
}
