//
//  GamesTests.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import XCTest
import CoreData
@testable import GNAR

class GamesTests: XCTestCase {
    var persistenceController: PersistenceController!
    var contexts: CoreDataContexts!
    var viewModel: ContentViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Set up in-memory persistence controller
        persistenceController = PersistenceController(inMemory: true)
        
        // Set up contexts with view and background context
        contexts = CoreDataContexts(
            viewContext: persistenceController.container.viewContext,
            backgroundContext: persistenceController.container.newBackgroundContext()
        )
        
        // Initialize ContentViewModel with CoreDataContexts
        viewModel = ContentViewModel(coreData: contexts)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        contexts = nil
        persistenceController = nil
        try super.tearDownWithError()
    }

    func testCreateNewGame() throws {
        // First, load a test mountain using our helper
        let mountain = JSONLoader.loadTestMountain(context: contexts.viewContext)
        XCTAssertNotNil(mountain, "Failed to create test mountain")
        
        // Create a test GameSession directly in Core Data
        let session = GameSession(context: contexts.viewContext)
        session.mountainName = mountain?.name ?? "Test Mountain"
        session.id = UUID()
        session.startDate = Date()
        
        // Create and add a test player
        let player = Player(context: contexts.viewContext)
        player.name = "Test Player"
        player.id = UUID()
        session.addToPlayers(player)
        
        try contexts.viewContext.save()
        
        // Use ContentViewModel to load the game sessions
        let expectation = XCTestExpectation(description: "Load sessions")
        
        Task {
            await viewModel.loadInitialSessions()
            
            XCTAssertNotNil(viewModel.sessionPreviews)
            XCTAssertEqual(viewModel.sessionPreviews?.count, 1)
            XCTAssertEqual(viewModel.sessionPreviews?.first?.mountainName, mountain?.name)
            XCTAssertEqual(viewModel.sessionPreviews?.first?.playerCount, 1)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testLoadSession() throws {
        // First, load a test mountain using our helper
        let mountain = JSONLoader.loadTestMountain(context: contexts.viewContext)
        XCTAssertNotNil(mountain, "Failed to create test mountain")
        
        // Create a test GameSession
        let session = GameSession(context: contexts.viewContext)
        session.mountainName = mountain?.name ?? "Test Mountain"
        let sessionID = UUID()
        session.id = sessionID
        session.startDate = Date()
        
        // Create and add a test player
        let player = Player(context: contexts.viewContext)
        player.name = "Test Player"
        player.id = UUID()
        session.addToPlayers(player)
        
        try contexts.viewContext.save()
        
        // Load the session by ID using the ContentViewModel
        viewModel.loadSession(by: sessionID)
        
        // Verify the session was loaded
        XCTAssertNotNil(viewModel.activeSession)
        XCTAssertEqual(viewModel.activeSession?.id, sessionID)
        XCTAssertEqual(viewModel.activeSession?.mountainName, mountain?.name)
        XCTAssertEqual(viewModel.activeSession?.playersArray.count, 1)
        XCTAssertEqual(viewModel.activeSession?.playersArray.first?.name, "Test Player")
    }
    
    func testCreateMultipleGames() throws {
        // Load a test mountain using our helper
        let mountain = JSONLoader.loadTestMountain(context: contexts.viewContext)
        XCTAssertNotNil(mountain, "Failed to create test mountain")
        
        // Create two test game sessions
        for i in 1...2 {
            let session = GameSession(context: contexts.viewContext)
            session.mountainName = mountain?.name ?? "Test Mountain"
            session.id = UUID()
            session.startDate = Date().addingTimeInterval(TimeInterval(-i * 3600)) // Different times
            
            // Create and add players
            for j in 1...i+1 {
                let player = Player(context: contexts.viewContext)
                player.name = "Test Player \(i)-\(j)"
                player.id = UUID()
                session.addToPlayers(player)
            }
        }
        
        try contexts.viewContext.save()
        
        // Verify we can load all sessions
        let expectation = XCTestExpectation(description: "Load multiple sessions")
        
        Task {
            await viewModel.loadInitialSessions()
            
            XCTAssertNotNil(viewModel.sessionPreviews)
            XCTAssertEqual(viewModel.sessionPreviews?.count, 2)
            
            // Check that sessions are sorted by date (most recent first)
            if let previews = viewModel.sessionPreviews, previews.count >= 2 {
                XCTAssertGreaterThan(
                    previews[0].date,
                    previews[1].date,
                    "Sessions should be sorted with most recent first"
                )
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}