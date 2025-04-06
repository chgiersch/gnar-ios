//
//  JSONLoaderTests.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import XCTest
import CoreData
@testable import GNAR

class JSONLoaderTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
        try super.tearDownWithError()
    }
    
    func testLoadSquallywoodData() throws {
        // Load the data
        JSONLoader.loadSquallywoodData(context: context)
        
        // Fetch the Mountain entity
        let fetchRequest: NSFetchRequest<Mountain> = Mountain.fetchRequest()
        let mountains = try context.fetch(fetchRequest)
        
        // Assert that the data was loaded correctly
        XCTAssertEqual(mountains.count, 1)
        
        let mountain = mountains.first
        XCTAssertEqual(mountain?.id, "squallywood-mountain")
        XCTAssertEqual(mountain?.name, "Squallywood")
        
        // Assert that the ECPs were loaded correctly
        let ecps = mountain?.ecps as? Set<ECP>
        XCTAssertEqual(ecps?.count, 30) // Adjust the count based on the actual number of ECPs
        
        // Assert that the LineWorths were loaded correctly
        let lineWorths = mountain?.lineWorths as? Set<LineWorth>
        XCTAssertEqual(lineWorths?.count, 100) // Adjust the count based on the actual number of LineWorths
    }
}