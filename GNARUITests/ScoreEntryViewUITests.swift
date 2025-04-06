//
//  ScoreEntryViewUITests.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//


// ScoreEntryViewUITests.swift
import XCTest

final class ScoreEntryViewUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testScoreEntryNavigation() throws {
        // Navigate to score entry
        app.tabBars.buttons["Games"].tap()
        app.buttons["New Game"].tap()
        
        // Select mountain
        let mountainCell = app.staticTexts["Free Range"]
        XCTAssertTrue(mountainCell.exists)
        mountainCell.tap()
        
        // Start game and add score
        app.buttons["Start"].tap()
        
        // Use accessibility identifier instead of "plus"
        let addButton = app.buttons["AddScoreButton"]
        XCTAssertTrue(addButton.exists, "Add score button should exist")
        addButton.tap()

        // Verify elements exist
        // Changed expectation to wait for the sheet to appear
        let scoreNavBar = app.navigationBars["New Score"]
        let exists = scoreNavBar.waitForExistence(timeout: 2)
        XCTAssertTrue(exists, "Score entry navigation bar should appear")

        XCTAssertTrue(app.buttons["Line"].exists)
        XCTAssertTrue(app.buttons["Trick"].exists)
        XCTAssertTrue(app.buttons["ECP"].exists)
        XCTAssertTrue(app.buttons["Penalty"].exists)
    }
}
