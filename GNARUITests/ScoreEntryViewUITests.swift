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
        
        // Wait for the New Game button and tap it
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 3), "New Game button not found within timeout")
        newGameButton.tap()
        
        // Wait for the Select Area section to appear - fixed to match actual case
        XCTAssertTrue(app.staticTexts["SELECT AREA"].waitForExistence(timeout: 2), "Select Area header not found")
        
        // Use index 3 for Squallywood (based on debug logs where we see Squallywood is index 3)
        let squallywoodText = app.staticTexts.element(boundBy: 3)
        XCTAssertEqual(squallywoodText.label, "Squallywood", "Item at index 3 should be Squallywood but was \(squallywoodText.label)")
        squallywoodText.tap()
        
        // Enter player names
        let playerTextField = app.textFields["You"]
        XCTAssertTrue(playerTextField.waitForExistence(timeout: 2), "Player text field not found")
        playerTextField.tap()
        playerTextField.typeText("Test Player 1")
        
        // Add a second player
        let addPlayerButton = app.buttons["Add Player"]
        XCTAssertTrue(addPlayerButton.waitForExistence(timeout: 2), "Add Player button not found")
        addPlayerButton.tap()
        
        // Enter name for second player
        let secondPlayerField = app.textFields.element(boundBy: 1) // Second text field
        XCTAssertTrue(secondPlayerField.waitForExistence(timeout: 2), "Second player text field not found")
        secondPlayerField.tap()
        secondPlayerField.typeText("Test Player 2")
        
        // Start game and add score
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2), "Start button not found")
        startButton.tap()
        
        // Use the proper accessibility identifier to find the Add Score button
        let addScoreButton = app.buttons["AddScoreButton"]
        XCTAssertTrue(addScoreButton.waitForExistence(timeout: 3), "Add score button not found within timeout")
        addScoreButton.tap()

        // Verify we're in the score entry screen
        let scoreNavBar = app.navigationBars["New Score"]
        XCTAssertTrue(scoreNavBar.waitForExistence(timeout: 2), "Score entry navigation bar not found")

        // Find and tap the Line button
        let lineButton = app.buttons["Line"]
        XCTAssertTrue(lineButton.waitForExistence(timeout: 2), "Line button not found")
        lineButton.tap()
        
        // A LineWorthPickerView should appear
        let lineWorthPicker = app.staticTexts["Select a Line"]
        XCTAssertTrue(lineWorthPicker.waitForExistence(timeout: 2), "Line worth picker view did not appear")
        
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
            
            let addButton = app.navigationBars.buttons["AddLineButton"]

            XCTAssertTrue(addButton.waitForExistence(timeout: 2), "Add button not found in navigation bar")
            addButton.tap()
            
            // Verify we returned to the score entry screen
            XCTAssertTrue(scoreNavBar.waitForExistence(timeout: 2), "Did not return to score entry screen")
            
            // Wait a bit longer for the UI to fully update after returning to score entry
            sleep(2)
            
            // Look for the "LINE WORTH" section header which appears when a line is added
            let lineWorthSection = app.staticTexts["LINE WORTH"]
            XCTAssertTrue(lineWorthSection.waitForExistence(timeout: 3), "LINE WORTH section not found after adding line")
            
            // The actual line name should appear in the form now
            let deadMansLineScore = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Dead Man'")).firstMatch
            
            // Print all text elements to debug what's actually visible
            for (i, text) in app.staticTexts.allElementsBoundByIndex.enumerated() {
                print("  Text \(i): '\(text.label)'")
            }
            
            // Check specifically for Dead Man's line
            XCTAssertTrue(deadMansLineScore.waitForExistence(timeout: 3), "Dead Man's line not found after selection")
        }
    }
    
    // Add a simplified test focusing just on mountain selection
    func testMountainSelection() throws {
        // Navigate to game creation
        app.tabBars.buttons["Games"].tap()
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 3), "New Game button not found")
        newGameButton.tap()
        
        // Debug info - print all text elements visible
        for (index, element) in app.staticTexts.allElementsBoundByIndex.enumerated() {
            print("  \(index): '\(element.label)'")
        }
        
        // Note: Form section headers are automatically rendered in uppercase by iOS
        // even if they're defined with title case in code
        XCTAssertTrue(app.staticTexts["SELECT AREA"].waitForExistence(timeout: 2), "Select Area header not found")
        
        // Wait a moment for animation to complete
        sleep(1)
        
        // Use index 3 for Squallywood from the debug logs
        let squallywoodText = app.staticTexts.element(boundBy: 3)
        XCTAssertEqual(squallywoodText.label, "Squallywood", "Text at index 3 should be Squallywood")
        squallywoodText.tap()
        
        // Enter player names
        let playerTextField = app.textFields["You"]
        XCTAssertTrue(playerTextField.waitForExistence(timeout: 2), "Player text field not found")
        playerTextField.tap()
        playerTextField.typeText("Test Player 1")
        
        // Add a second player
        let addPlayerButton = app.buttons["Add Player"]
        XCTAssertTrue(addPlayerButton.waitForExistence(timeout: 2), "Add Player button not found")
        addPlayerButton.tap()
        
        // Enter name for second player
        let secondPlayerField = app.textFields.element(boundBy: 1) // Second text field
        XCTAssertTrue(secondPlayerField.waitForExistence(timeout: 2), "Second player text field not found")
        secondPlayerField.tap()
        secondPlayerField.typeText("Test Player 2")
        
        // Check if we can proceed with Start
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2), "Start button not found")
    }
}
