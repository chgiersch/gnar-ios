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

    func testLoadSquallywoodMountainJSON() {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Manually load JSON into context
        JSONLoader.loadSquallywoodData(context: context)

        do {
            let fetchRequest: NSFetchRequest<Mountain> = Mountain.fetchRequest()
            let mountains = try context.fetch(fetchRequest)
            XCTAssertFalse(mountains.isEmpty, "No mountains loaded from JSON")

            guard let mountain = mountains.first else {
                XCTFail("No Mountain found")
                return
            }

            print("✅ Mountain name: \(mountain.name)")
            print("🏔️ ID: \(mountain.id)")
            print("📈 ECP count: \(mountain.ecps?.count ?? 0)")
            print("📊 LineWorth count: \(mountain.lineWorths?.count ?? 0)")

            XCTAssertGreaterThan(mountain.ecps?.count ?? 0, 0, "ECPs not loaded")
            XCTAssertGreaterThan(mountain.lineWorths?.count ?? 0, 0, "LineWorths not loaded")

            // Optionally test reverse relationships
            if let ecps = mountain.ecps as? Set<ECP> {
                for ecp in ecps {
                    XCTAssertNotNil(ecp.mountain, "ECP missing mountain reference")
                }
            }

            if let lineWorths = mountain.lineWorths as? Set<LineWorth> {
                for line in lineWorths {
                    XCTAssertNotNil(line.mountain, "LineWorth missing mountain reference")
                }
            }

        } catch {
            XCTFail("Fetching Mountain failed: \(error)")
        }
    }
}
