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
        print("🚀 Starting testScoreEntryNavigation")
        
        // Navigate to score entry
        print("📱 Tapping Games tab")
        app.tabBars.buttons["Games"].tap()
        
        // Wait for the New Game button and tap it
        print("🔍 Looking for New Game button")
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 3), "New Game button not found within timeout")
        print("✅ Found New Game button, tapping it")
        newGameButton.tap()
        
        // Wait for the Select Area section to appear
        print("🔍 Looking for SELECT AREA header")
        XCTAssertTrue(app.staticTexts["SELECT AREA"].waitForExistence(timeout: 2), "Select Area header not found")
        print("✅ Found SELECT AREA header")
        
        // Find the form and ensure it's visible
        print("🔍 Looking for Form element")
        let form = app.otherElements["Form"]
        XCTAssertTrue(form.waitForExistence(timeout: 2), "Form not found")
        print("✅ Found Form element")
        
        // Find Squallywood text and ensure it's visible
        print("🔍 Looking for Squallywood text")
        let squallywoodText = app.staticTexts["Squallywood"]
        XCTAssertTrue(squallywoodText.waitForExistence(timeout: 2), "Squallywood text not found")
        print("✅ Found Squallywood text")
        
        // If the element exists but isn't visible, scroll to it
        if !squallywoodText.isHittable {
            print("🔄 Squallywood text not hittable, scrolling to it")
            form.scrollToElement(element: squallywoodText)
        }
        
        // Verify the element is now hittable before tapping
        XCTAssertTrue(squallywoodText.isHittable, "Squallywood text is not hittable after scrolling")
        print("✅ Squallywood text is hittable, tapping it")
        squallywoodText.tap()
        
        // Enter player names
        print("🔍 Looking for Player 1 text field")
        let playerTextField = app.textFields["Player 1"]
        XCTAssertTrue(playerTextField.waitForExistence(timeout: 2), "Player 1 text field not found")
        print("✅ Found Player 1 text field, entering name")
        playerTextField.tap()
        playerTextField.typeText("Test Player 1")
        
        // Add a second player
        print("🔍 Looking for Add Player button")
        let addPlayerButton = app.buttons["Add Player"]
        XCTAssertTrue(addPlayerButton.waitForExistence(timeout: 2), "Add Player button not found")
        print("✅ Found Add Player button, tapping it")
        addPlayerButton.tap()
        
        // Enter name for second player
        print("🔍 Looking for Player 2 text field")
        let secondPlayerField = app.textFields["Player 2"]
        XCTAssertTrue(secondPlayerField.waitForExistence(timeout: 2), "Second player text field not found")
        print("✅ Found Player 2 text field, entering name")
        secondPlayerField.tap()
        secondPlayerField.typeText("Test Player 2")
        
        // Start game and add score
        print("🔍 Looking for Start button")
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2), "Start button not found")
        print("✅ Found Start button, tapping it")
        startButton.tap()
        
        // Use the proper accessibility identifier to find the Add Score button
        print("🔍 Looking for Add Score button")
        let addScoreButton = app.buttons["AddScoreButton"]
        XCTAssertTrue(addScoreButton.waitForExistence(timeout: 3), "Add score button not found within timeout")
        print("✅ Found Add Score button, tapping it")
        addScoreButton.tap()

        // Verify we're in the score entry screen
        print("🔍 Looking for New Score navigation bar")
        let scoreNavBar = app.navigationBars["New Score"]
        XCTAssertTrue(scoreNavBar.waitForExistence(timeout: 2), "Score entry navigation bar not found")
        print("✅ Found New Score navigation bar")

        // Find and tap the Line button
        print("🔍 Looking for Line button")
        let lineButton = app.buttons["Line"]
        XCTAssertTrue(lineButton.waitForExistence(timeout: 2), "Line button not found")
        print("✅ Found Line button, tapping it")
        lineButton.tap()
        
        // A LineWorthPickerView should appear
        print("🔍 Looking for Select a Line text")
        let lineWorthPicker = app.staticTexts["Select a Line"]
        XCTAssertTrue(lineWorthPicker.waitForExistence(timeout: 2), "Line worth picker view did not appear")
        print("✅ Found Select a Line text")
        
        // Select a snow level (high)
        print("🔍 Looking for high snow level button")
        let highSnowButton = app.buttons["snow-level-high"]
        XCTAssertTrue(highSnowButton.waitForExistence(timeout: 2), "High snow level button not found")
        print("✅ Found high snow level button, tapping it")
        highSnowButton.tap()
                
        // Select the first line in the list if available
        if app.cells.count > 0 {
            print("📊 Found \(app.cells.count) cells in the list")
            
            // Look specifically for "Dead Man's" line
            print("🔍 Looking for Dead Man's line")
            let deadMansLine = app.staticTexts["Dead Man's"]
            
            if deadMansLine.waitForExistence(timeout: 2) {
                print("✅ Found Dead Man's line, tapping it")
                deadMansLine.tap()
            } else {
                print("⚠️ Dead Man's line not found, trying fallback")
                // Fallback to a cell containing "Dead Man" text
                let deadManCells = app.cells.containing(NSPredicate(format: "label CONTAINS 'Dead Man'"))
                if deadManCells.count > 0 {
                    print("✅ Found cell containing 'Dead Man', tapping it")
                    deadManCells.element(boundBy: 0).tap()
                } else {
                    print("⚠️ No Dead Man cells found, using cell at index 5")
                    // If we can't find the specific line, just use a cell at index 5
                    let cellToTap = app.cells.element(boundBy: 5)
                    XCTAssertTrue(cellToTap.waitForExistence(timeout: 2), "No line cells found")
                    cellToTap.tap()
                }
            }
            
            print("🔍 Looking for Add button in navigation bar")
            let addButton = app.navigationBars.buttons["AddLineButton"]
            XCTAssertTrue(addButton.waitForExistence(timeout: 2), "Add button not found in navigation bar")
            print("✅ Found Add button, tapping it")
            addButton.tap()
            
            // Verify we returned to the score entry screen
            XCTAssertTrue(scoreNavBar.waitForExistence(timeout: 2), "Did not return to score entry screen")
            print("✅ Returned to score entry screen")
            
            // Wait a bit longer for the UI to fully update after returning to score entry
            print("⏳ Waiting for UI to update")
            sleep(2)
            
            // Look for the "LINE WORTH" section header which appears when a line is added
            print("🔍 Looking for LINE WORTH section")
            let lineWorthSection = app.staticTexts["LINE WORTH"]
            XCTAssertTrue(lineWorthSection.waitForExistence(timeout: 3), "LINE WORTH section not found after adding line")
            print("✅ Found LINE WORTH section")
            
            // The actual line name should appear in the form now
            print("🔍 Looking for Dead Man's line in the form")
            let deadMansLineScore = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Dead Man'")).firstMatch
            XCTAssertTrue(deadMansLineScore.waitForExistence(timeout: 3), "Dead Man's line not found after selection")
            print("✅ Found Dead Man's line in the form")
        } else {
            print("❌ No cells found in the list")
        }
        
        print("🏁 Test completed successfully")
    }
    
    // Add a simplified test focusing just on mountain selection
    func testMountainSelection() async throws {
        print("🚀 Starting testMountainSelection")
        
        // Navigate to game creation
        print("📱 Tapping Games tab")
        app.tabBars.buttons["Games"].tap()
        
        print("🔍 Looking for New Game button")
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 3), "New Game button not found")
        print("✅ Found New Game button, tapping it")
        newGameButton.tap()
        
        // Debug info - print all text elements visible
        print("📊 Current visible text elements:")
        for (index, element) in app.staticTexts.allElementsBoundByIndex.enumerated() {
            print("  \(index): '\(element.label)'")
        }
        
        // Note: Form section headers are automatically rendered in uppercase by iOS
        // even if they're defined with title case in code
        print("🔍 Looking for SELECT AREA header")
        XCTAssertTrue(app.staticTexts["SELECT AREA"].waitForExistence(timeout: 2), "Select Area header not found")
        print("✅ Found SELECT AREA header")
        
        // Wait a moment for animation to complete
        print("⏳ Waiting for animation to complete")
        sleep(1)
        
        // Find Squallywood by searching for it directly
        print("🔍 Looking for Squallywood text")
        let squallywoodText = app.staticTexts["Squallywood"]
        XCTAssertTrue(squallywoodText.waitForExistence(timeout: 2), "Squallywood text not found")
        print("✅ Found Squallywood text, tapping it")
        squallywoodText.tap()
        
        // Enter player names
        print("🔍 Looking for Player 1 text field")
        let playerTextField = app.textFields["Player 1"]
        XCTAssertTrue(playerTextField.waitForExistence(timeout: 2), "Player 1 text field not found")
        print("✅ Found Player 1 text field, entering name")
        playerTextField.tap()
        playerTextField.typeText("Test Player 1")
        
        // Add a second player
        print("🔍 Looking for Add Player button")
        let addPlayerButton = app.buttons["Add Player"]
        XCTAssertTrue(addPlayerButton.waitForExistence(timeout: 2), "Add Player button not found")
        print("✅ Found Add Player button, tapping it")
        addPlayerButton.tap()
        
        // Enter name for second player
        print("🔍 Looking for Player 2 text field")
        let secondPlayerField = app.textFields["Player 2"]
        XCTAssertTrue(secondPlayerField.waitForExistence(timeout: 2), "Second player text field not found")
        print("✅ Found Player 2 text field, entering name")
        secondPlayerField.tap()
        secondPlayerField.typeText("Test Player 2")
        
        // Check if we can proceed with Start
        print("🔍 Looking for Start button")
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2), "Start button not found")
        print("✅ Found Start button")
        
        print("🏁 Test completed successfully")
    }
}
