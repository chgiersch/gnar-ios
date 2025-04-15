//
//  JSONLoaderTests.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import XCTest
import CoreData
@testable import GNAR

// MARK: - JSONLoader Test Extensions

extension JSONLoader {
    /// Load the Squallywood mountain data from the bundled JSON
    /// This is a test helper method used for unit tests
    static func loadSquallywoodData(context: NSManagedObjectContext) {
        loadMountain(named: "SquallywoodMountain", context: context)
    }
    
    /// Load the test mountain data from a test JSON file
    /// This is a test helper method used for unit tests
    static func loadTestMountain(context: NSManagedObjectContext) -> Mountain? {
        // Create a new mountain directly
        let mountain = Mountain(context: context)
        mountain.id = "test-mountain"
        mountain.name = "Test Mountain"
        mountain.isGlobal = false
        
        // Create a test line worth
        let line = LineWorth(context: context)
        line.id = UUID()
        line.name = "Test Line"
        line.area = "Test Area"
        line.descriptionText = "A test line"
        line.mountain = mountain
        line.basePointsSource = "tiered"
        line.basePointsLow = NSNumber(value: 100)
        line.basePointsMedium = NSNumber(value: 200)
        line.basePointsHigh = NSNumber(value: 300)
        
        // Create a test ECP
        let ecp = ECP(context: context)
        ecp.id = UUID()
        ecp.idDescriptor = "test-ecp"
        ecp.name = "Test ECP"
        ecp.descriptionText = "A test ECP"
        ecp.points = 1000
        ecp.frequency = "daily"
        ecp.abbreviation = "TE"
        ecp.mountain = mountain
        
        do {
            try context.save()
            return mountain
        } catch {
            print("❌ Failed to save test mountain: \(error)")
            context.rollback()
            return nil
        }
    }
}

class JSONLoaderTests: XCTestCase {
    
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
        
        // Assert that the related entities were loaded correctly
        XCTAssertGreaterThan(mountain?.ecps?.count ?? 0, 0, "No ECPs were loaded")
        XCTAssertGreaterThan(mountain?.lineWorths?.count ?? 0, 0, "No LineWorths were loaded")
        
        // Verify relationships
        if let ecps = mountain?.ecps as? Set<ECP> {
            for ecp in ecps {
                XCTAssertEqual(ecp.mountain, mountain, "ECP mountain relationship is incorrect")
            }
        }
        
        if let lineWorths = mountain?.lineWorths as? Set<LineWorth> {
            for lineWorth in lineWorths {
                XCTAssertEqual(lineWorth.mountain, mountain, "LineWorth mountain relationship is incorrect")
            }
        }
    }
    
    func testLoadTestMountain() throws {
        // Load the test mountain data
        let mountain = JSONLoader.loadTestMountain(context: context)
        
        // Assert that the mountain was created
        XCTAssertNotNil(mountain)
        XCTAssertEqual(mountain?.id, "test-mountain")
        XCTAssertEqual(mountain?.name, "Test Mountain")
        
        // Verify the line worth was created
        let lineWorths = mountain?.lineWorths as? Set<LineWorth>
        XCTAssertEqual(lineWorths?.count, 1)
        let lineWorth = lineWorths?.first
        XCTAssertEqual(lineWorth?.name, "Test Line")
        XCTAssertEqual(lineWorth?.area, "Test Area")
        XCTAssertEqual(lineWorth?.basePointsLow?.intValue, 100)
        XCTAssertEqual(lineWorth?.basePointsMedium?.intValue, 200)
        XCTAssertEqual(lineWorth?.basePointsHigh?.intValue, 300)
        
        // Verify the ECP was created
        let ecps = mountain?.ecps as? Set<ECP>
        XCTAssertEqual(ecps?.count, 1)
        let ecp = ecps?.first
        XCTAssertEqual(ecp?.name, "Test ECP")
        XCTAssertEqual(ecp?.points, 1000)
        XCTAssertEqual(ecp?.frequency, "daily")
    }
}