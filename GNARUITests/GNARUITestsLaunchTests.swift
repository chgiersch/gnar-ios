//
//  GNARUITestsLaunchTests.swift
//  GNARUITests
//
//  Created by Chris Giersch on 3/28/25.
//

import XCTest

@MainActor
final class GNARUITestsLaunchTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testLaunch() async throws {
        app.launch()
        
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
