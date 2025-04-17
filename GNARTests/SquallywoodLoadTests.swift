//
//  SquallywoodLoadTests.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//

import XCTest
import CoreData
@testable import GNAR

final class SquallywoodLoadTests: XCTestCase {
    
    var coreDataStack: CoreDataStack!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack(inMemory: true)
        context = coreDataStack.viewContext
    }
    
    override func tearDown() {
        coreDataStack = nil
        super.tearDown()
    }

    func testLoadSquallywoodMountainJSON() throws {
        // Manually load JSON into context
        JSONLoader.loadSquallywoodData(context: context)

        // Fetch the mountains
        let fetchRequest: NSFetchRequest<Mountain> = Mountain.fetchRequest()
        let mountains = try context.fetch(fetchRequest)
        XCTAssertFalse(mountains.isEmpty, "No mountains loaded from JSON")

        guard let mountain = mountains.first else {
            XCTFail("No Mountain found")
            return
        }

        // Verify the basic mountain attributes
        XCTAssertEqual(mountain.name, "Squallywood", "Mountain name doesn't match expected value")
        XCTAssertEqual(mountain.id, "squallywood-mountain", "Mountain ID doesn't match expected value")
        
        // Verify that we have loaded some data
        XCTAssertGreaterThan(mountain.ecps?.count ?? 0, 10, "Not enough ECPs loaded")
        XCTAssertGreaterThan(mountain.lineWorths?.count ?? 0, 10, "Not enough LineWorths loaded")

        // Verify that relationships are properly established
        if let ecps = mountain.ecps as? Set<ECP> {
            for ecp in ecps {
                XCTAssertNotNil(ecp.mountain, "ECP missing mountain reference")
                XCTAssertEqual(ecp.mountain, mountain, "ECP points to wrong mountain")
                XCTAssertFalse(ecp.name.isEmpty, "ECP has empty name")
                XCTAssertGreaterThan(ecp.points, 0, "ECP has zero or negative points")
            }
        }

        if let lineWorths = mountain.lineWorths as? Set<LineWorth> {
            for line in lineWorths {
                XCTAssertNotNil(line.mountain, "LineWorth missing mountain reference")
                XCTAssertEqual(line.mountain, mountain, "LineWorth points to wrong mountain")
                XCTAssertFalse(line.name.isEmpty, "LineWorth has empty name")
                XCTAssertFalse(line.area.isEmpty, "LineWorth has empty area")
            }
        }
    }
    
    func testCompareSquallywoodAndTestMountain() throws {
        // Load both mountains
        JSONLoader.loadSquallywoodData(context: context)
        let testMountain = JSONLoader.loadTestMountain(context: context)
        
        // Fetch all mountains
        let fetchRequest: NSFetchRequest<Mountain> = Mountain.fetchRequest()
        let mountains = try context.fetch(fetchRequest)
        XCTAssertEqual(mountains.count, 2, "Expected exactly 2 mountains")
        
        // Find the squallywood mountain
        let squallywood = mountains.first { $0.id == "squallywood-mountain" }
        XCTAssertNotNil(squallywood, "Squallywood mountain not found")
        
        // Compare some attributes
        XCTAssertNotEqual(squallywood?.id, testMountain?.id, "Mountains should have different IDs")
        XCTAssertNotEqual(squallywood?.name, testMountain?.name, "Mountains should have different names")
        XCTAssertGreaterThan(squallywood?.ecps?.count ?? 0, testMountain?.ecps?.count ?? 0, "Squallywood should have more ECPs")
        XCTAssertGreaterThan(squallywood?.lineWorths?.count ?? 0, testMountain?.lineWorths?.count ?? 0, "Squallywood should have more LineWorths")
    }
}
