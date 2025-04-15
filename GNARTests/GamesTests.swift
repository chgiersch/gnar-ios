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
    var coreDataStack: CoreDataStack!
    var viewModel: ContentViewModel!

    override func setUp() async throws {
        try await super.setUp()
        coreDataStack = CoreDataStack(inMemory: true)
        await MainActor.run {
            viewModel = ContentViewModel(coreDataStack: coreDataStack)
        }
    }

    override func tearDown() async throws {
        await MainActor.run {
            coreDataStack = nil
            viewModel = nil
        }
        try await super.tearDown()
    }

    func testCreateNewGame() async throws {
        // First, load a test mountain using our helper
        let mountain = JSONLoader.loadTestMountain(context: coreDataStack.viewContext)
        XCTAssertNotNil(mountain, "Failed to create test mountain")
        
        // Create a test GameSession directly in Core Data
        let session = GameSession(context: coreDataStack.viewContext)
        session.mountainName = mountain?.name ?? "Test Mountain"
        session.id = UUID()
        session.startDate = Date()
        
        // Create and add a test player
        let player = Player(context: coreDataStack.viewContext)
        player.name = "Test Player"
        player.id = UUID()
        session.addToPlayers(player)
        
        try coreDataStack.viewContext.save()
        
        // Use ContentViewModel to load the game sessions
        await viewModel.loadSessionPreviews()
        
        // Verify the results on the MainActor
        await MainActor.run {
            XCTAssertNotNil(viewModel.sessionPreviews)
            XCTAssertEqual(viewModel.sessionPreviews?.count, 1)
            XCTAssertEqual(viewModel.sessionPreviews?.first?.mountainName, mountain?.name)
            XCTAssertEqual(viewModel.sessionPreviews?.first?.playerCount, 1)
        }
    }

    func testLoadSession() async throws {
        // First, load a test mountain using our helper
        let mountain = JSONLoader.loadTestMountain(context: coreDataStack.viewContext)
        XCTAssertNotNil(mountain, "Failed to create test mountain")
        
        // Create a test GameSession
        let session = GameSession(context: coreDataStack.viewContext)
        session.mountainName = mountain?.name ?? "Test Mountain"
        let sessionID = UUID()
        session.id = sessionID
        session.startDate = Date()
        
        // Create and add a test player
        let player = Player(context: coreDataStack.viewContext)
        player.name = "Test Player"
        player.id = UUID()
        session.addToPlayers(player)
        
        try coreDataStack.viewContext.save()
        
        // Load the session by ID using the ContentViewModel
        await viewModel.loadSession(id: sessionID)
        
        // Verify the session was loaded on the MainActor
        await MainActor.run {
            XCTAssertNotNil(viewModel.selectedSession)
            XCTAssertEqual(viewModel.selectedSession?.id, sessionID)
            XCTAssertEqual(viewModel.selectedSession?.mountainName, mountain?.name)
            XCTAssertEqual(viewModel.selectedSession?.playersArray.count, 1)
            XCTAssertEqual(viewModel.selectedSession?.playersArray.first?.name, "Test Player")
        }
    }
    
    func testCreateMultipleGames() async throws {
        // Load a test mountain using our helper
        let mountain = JSONLoader.loadTestMountain(context: coreDataStack.viewContext)
        XCTAssertNotNil(mountain, "Failed to create test mountain")
        
        // Create multiple test GameSessions
        for i in 1...3 {
            let session = GameSession(context: coreDataStack.viewContext)
            session.mountainName = mountain?.name ?? "Test Mountain"
            session.id = UUID()
            session.startDate = Date()
            
            // Create and add a test player
            let player = Player(context: coreDataStack.viewContext)
            player.name = "Test Player \(i)"
            player.id = UUID()
            session.addToPlayers(player)
        }
        
        try coreDataStack.viewContext.save()
        
        // Use ContentViewModel to load the game sessions
        await viewModel.loadSessionPreviews()
        
        // Verify the results on the MainActor
        await MainActor.run {
            XCTAssertNotNil(viewModel.sessionPreviews)
            XCTAssertEqual(viewModel.sessionPreviews?.count, 3)
            
            // Verify each session has the correct player
            for i in 0..<3 {
                XCTAssertEqual(viewModel.sessionPreviews?[i].playerCount, 1)
            }
        }
    }
}