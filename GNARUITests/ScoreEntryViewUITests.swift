//
//  GNARUITests.swift
//  GNARUITests
//
//  Created by Chris Giersch on 3/28/25.
//

import XCTest

extension XCUIElement {
    func scrollToElement(element: XCUIElement) {
        while !element.isHittable {
            swipeUp()
        }
    }
}

@MainActor
final class GNARUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }
    
    func testScoreEntryNavigation() async throws {
        // Navigate to score entry
        app.tabBars.buttons["Games"].tap()
        
        // Wait for the New Game button and tap it
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 3), "New Game button not found within timeout")
        newGameButton.tap()
        
        // Wait for the Select Area section to appear
        XCTAssertTrue(app.staticTexts["SELECT AREA"].waitForExistence(timeout: 2), "Select Area header not found")
        
        // Find Squallywood text and tap it
        let squallywoodText = app.buttons["mountain-Squallywood"]
        XCTAssertTrue(squallywoodText.waitForExistence(timeout: 2), "Squallywood button not found")
        squallywoodText.tap()
        
        // Enter player names
        let playerTextField = app.textFields["Player 1"]
        XCTAssertTrue(playerTextField.waitForExistence(timeout: 2), "Player 1 text field not found")
        playerTextField.tap()
        playerTextField.typeText("Test Player 1")
        
        // Add a second player
        let addPlayerButton = app.buttons["AddPlayerButton"]
        XCTAssertTrue(addPlayerButton.waitForExistence(timeout: 2), "Add Player button not found")
        addPlayerButton.tap()
        
        // Enter name for second player
        let secondPlayerField = app.textFields["Player 2"]
        XCTAssertTrue(secondPlayerField.waitForExistence(timeout: 2), "Second player text field not found")
        secondPlayerField.tap()
        secondPlayerField.typeText("Test Player 2")
        
        // Start game and add score
        let startButton = app.buttons["StartGameButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2), "Start button not found")
        startButton.tap()
        
        // Use the proper accessibility identifier to find the Add Score button
        let addScoreButton = app.buttons["AddScoreButton"]
        XCTAssertTrue(addScoreButton.waitForExistence(timeout: 3), "Add score button not found within timeout")
        addScoreButton.tap()

        // Verify we're in the score entry screen
        let scoreNavBar = app.navigationBars["Score Entry"]
        XCTAssertTrue(scoreNavBar.waitForExistence(timeout: 2), "Score entry navigation bar not found")

        // Find and tap the Line button
        let lineButton = app.buttons["LineButton"]
        XCTAssertTrue(lineButton.waitForExistence(timeout: 2), "Line button not found")
        lineButton.tap()

        // Allow more time for the picker to appear (sometimes navigation animations can take time)
        let lineWorthPicker = app.navigationBars["Select a Line"]
        XCTAssertTrue(lineWorthPicker.waitForExistence(timeout: 5), "Line worth picker view did not appear")
        
        // Debug info - print out available navigation bars 
        if !lineWorthPicker.exists {
            XCTContext.runActivity(named: "Debug Navigation Structure") { _ in
                let navBars = app.navigationBars.allElementsBoundByIndex
                XCTContext.runActivity(named: "Available Navigation Bars: \(navBars.count)") { _ in
                    for (index, navBar) in navBars.enumerated() {
                        XCTContext.runActivity(named: "Nav \(index): \(navBar.identifier)") { _ in
                            XCTAssertTrue(true) // Just to output the debug info
                        }
                    }
                }
            }
        }
        
        // Select a snow level (high)
        let highSnowButton = app.buttons["snow-level-high"]
        XCTAssertTrue(highSnowButton.waitForExistence(timeout: 2), "High snow level button not found")
        highSnowButton.tap()
                
        // Select the first line in the list if available
        if app.cells.count > 0 {
            // Look specifically for "Dead Man's" line
            let deadMansLine = app.staticTexts["Dead Man's"]
            
            if deadMansLine.waitForExistence(timeout: 2) {
                deadMansLine.tap()
            } else {
                // Fallback to a cell containing "Dead Man" text
                let deadManCells = app.cells.containing(NSPredicate(format: "label CONTAINS 'Dead Man'"))
                if deadManCells.count > 0 {
                    deadManCells.element(boundBy: 0).tap()
                } else {
                    // If we can't find the specific line, just use a cell at index 5
                    let cellToTap = app.cells.element(boundBy: 5)
                    XCTAssertTrue(cellToTap.waitForExistence(timeout: 2), "No line cells found")
                    cellToTap.tap()
                }
            }
            
            // Look for the "LINE WORTH" section header which appears when a line is added
            let lineWorthSection = app.staticTexts["LINE"]
            XCTAssertTrue(lineWorthSection.waitForExistence(timeout: 3), "LINE section not found after adding line")
            
            // The actual line name should appear in the form now
            let deadMansLineScore = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Dead Man'")).firstMatch
            XCTAssertTrue(deadMansLineScore.waitForExistence(timeout: 3), "Dead Man's line not found after selection")
            
            let addButton = app.navigationBars.buttons["AddLineButton"]
            XCTAssertTrue(addButton.waitForExistence(timeout: 2), "Add button not found in navigation bar")
            addButton.tap()
            
            // Verify we returned to the score entry screen
            XCTAssertTrue(scoreNavBar.waitForExistence(timeout: 2), "Did not return to score entry screen")
            
            // Give UI time to update after returning to score entry
            sleep(1)
            
        } else {
            XCTFail("No cells found in the line list")
        }
    }
    
    // Add a simplified test focusing just on mountain selection
    func testMountainSelection() async throws {
        // Navigate to game creation
        app.tabBars.buttons["Games"].tap()
        
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 3), "New Game button not found")
        newGameButton.tap()
        
        // Note: Form section headers are automatically rendered in uppercase by iOS
        XCTAssertTrue(app.staticTexts["SELECT AREA"].waitForExistence(timeout: 2), "Select Area header not found")
        
        // Wait a moment for animation to complete
        sleep(1)
        
        // Find Squallywood by accessibility identifier
        let squallywoodText = app.buttons["mountain-Squallywood"]
        XCTAssertTrue(squallywoodText.waitForExistence(timeout: 2), "Squallywood button not found")
        squallywoodText.tap()
        
        // Enter player names
        let playerTextField = app.textFields["Player 1"]
        XCTAssertTrue(playerTextField.waitForExistence(timeout: 2), "Player 1 text field not found")
        playerTextField.tap()
        playerTextField.typeText("Test Player 1")
        
        // Add a second player
        let addPlayerButton = app.buttons["AddPlayerButton"]
        XCTAssertTrue(addPlayerButton.waitForExistence(timeout: 2), "Add Player button not found")
        addPlayerButton.tap()

        // Enter name for second player
        let secondPlayerField = app.textFields["Player 2"]
        XCTAssertTrue(secondPlayerField.waitForExistence(timeout: 2), "Second player text field not found")
        secondPlayerField.tap()
        secondPlayerField.typeText("Test Player 2")
        
        // Check if we can proceed with Start
        let startButton = app.buttons["StartGameButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2), "Start button not found")
    }
}
