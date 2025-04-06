//
//  JSONLoader.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import Foundation
import CoreData

class JSONLoader {
    /// Loads a mountain from a bundled JSON file by name, decoding trick bonuses, penalties,
    /// ECPs, and LineWorths if they exist, and saving all to Core Data.
    ///
    /// - Parameters:
    ///   - filename: The name of the bundled JSON file (without `.json` extension)
    ///   - context: The Core Data context into which the data will be saved
    static func loadMountain(named filename: String, context: NSManagedObjectContext) {
        print("🚀 Beginning load of mountain JSON: \(filename).json")

        // Find JSON file in the main bundle
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("⚠️ \(filename).json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            print("📦 Successfully read JSON data from \(filename).json")

            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.context!] = context

            // Decode the universal payload wrapper which contains optional arrays
            let payload = try decoder.decode(UniversalMountainPayload.self, from: data)

            // Create the core Mountain entity
            let mountain = Mountain(context: context)
            mountain.id = payload.id
            mountain.name = payload.name
            let globalMountainIDs: Set<String> = ["Global"]
            mountain.isGlobal = globalMountainIDs.contains(payload.id)

            print("🗻 Created Mountain entity: \(mountain.name)")

            // Load Trick Bonuses if present
            if let bonuses = payload.trickBonuses {
                print("🎯 Loading \(bonuses.count) Trick Bonuses...")
                for bonus in bonuses {
                    let obj = TrickBonus(context: context)
                    obj.id = bonus.id
                    obj.name = bonus.name
                    obj.points = Int32(bonus.points)
                    obj.descriptionText = ""
                    obj.requiresVerification = false
                    obj.category = nil
                    obj.mountain = mountain
                }
                print("✅ Trick Bonuses loaded successfully")
            }

            // Load Penalties if present
            if let penalties = payload.penalties {
                print("🛑 Loading \(penalties.count) Penalties...")
                for penalty in penalties {
                    let obj = Penalty(context: context)
                    obj.id = penalty.id
                    obj.name = penalty.name
                    obj.descriptionText = penalty.descriptionText
                    obj.points = Int32(penalty.points)
                    obj.abbreviation = penalty.abbreviation
                    obj.mountain = mountain
                }
                print("✅ Penalties loaded successfully")
            }

            // Load ECPs (Extra Credit Points) if present
            if let ecps = payload.ecps {
                print("✨ Loading \(ecps.count) ECPs...")
                for ecp in ecps {
                    let obj = ECP(context: context)
                    obj.id = ecp.id
                    obj.name = ecp.name
                    obj.descriptionText = ecp.descriptionText
                    obj.points = Int32(ecp.points)
                    obj.frequency = ecp.frequency
                    obj.abbreviation = ecp.abbreviation
                    obj.mountain = mountain
                }
                print("✅ ECPs loaded successfully")
            }

            // Load LineWorths (lines on the mountain) if present
            if let lines = payload.lineWorths {
                print("⛷️ Loading \(lines.count) LineWorths...")
                for line in lines {
                    let obj = LineWorth(context: context)
                    obj.id = UUID().uuidString
                    obj.name = line.name
                    obj.area = line.area
                    obj.descriptionText = ""
                    obj.mountain = mountain

                    // Handle snow level scoring structure
                    switch line.basePoints {
                    case .single(let value):
                        obj.basePointsSource = "flat"
                        let number = NSNumber(value: value)
                        obj.basePointsLow = number
                        obj.basePointsMedium = number
                        obj.basePointsHigh = number

                    case .tiered(let low, let medium, let high):
                        obj.basePointsSource = "tiered"
                        obj.basePointsLow = low.map { NSNumber(value: $0) }
                        obj.basePointsMedium = medium.map { NSNumber(value: $0) }
                        obj.basePointsHigh = high.map { NSNumber(value: $0) }
                    }
                }
                print("✅ LineWorths loaded successfully")
            }

            // Save all entities to Core Data
            try context.save()
            print("💾 Mountain '\(mountain.name)' saved successfully to Core Data")
            
            // Save version from JSON into UserDefaults
            if let version = payload.version {
                SeedVersionManager.shared.markVersion(version, for: payload.id)
                print("🧠 Stored version \(version) for \(payload.id)")
            }
        } catch {
            print("❌ Failed to load or decode mountain \(filename): \(error.localizedDescription)")
            context.rollback()
        }
    }

    static func loadSquallywoodData(context: NSManagedObjectContext) {
        guard let url = Bundle.main.url(forResource: "SquallywoodMountain", withExtension: "json") else {
            print("SquallywoodMountain.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            print("JSON data loaded successfully")
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.context!] = context
            let squallywoodData = try decoder.decode(Mountain.self, from: data)
            print("JSON data decoded successfully")

            // Save the context
            try context.save()
            print("Context saved successfully")
        } catch {
            print("Failed to load Squallywood data: \(error)")
            context.rollback()
        }
    }
}

// Extend CodingUserInfoKey to include context
extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}
