//
//  GamesViewModelTests.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import XCTest
import CoreData
@testable import GNAR

class GamesViewModelTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var viewModel: GamesViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        viewModel = GamesViewModel(context: context)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        context = nil
        persistenceController = nil
        try super.tearDownWithError()
    }

    func testCreateNewGame() throws {
        let player = Player(context: context)
        player.name = "Test Player"
        viewModel.createNewGame(mountainName: "Test Mountain", players: [player])

        XCTAssertEqual(viewModel.sessions.count, 1)
        XCTAssertEqual(viewModel.sessions.first?.mountainName, "Test Mountain")
        XCTAssertEqual(viewModel.sessions.first?.players?.count, 1)
        XCTAssertEqual((viewModel.sessions.first?.players?.allObjects.first as? Player)?.name, "Test Player")
    }

    func testLoadSessions() throws {
        let player = Player(context: context)
        player.name = "Test Player"
        viewModel.createNewGame(mountainName: "Test Mountain", players: [player])

        let newViewModel = GamesViewModel(context: context)
        newViewModel.loadSessions()

        XCTAssertEqual(newViewModel.sessions.count, 1)
        XCTAssertEqual(newViewModel.sessions.first?.mountainName, "Test Mountain")
        XCTAssertEqual(newViewModel.sessions.first?.players?.count, 1)
        XCTAssertEqual((newViewModel.sessions.first?.players?.allObjects.first as? Player)?.name, "Test Player")
    }
}