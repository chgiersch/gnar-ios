//
//  LineWorth.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//

import Foundation
import CoreData

@objc(LineWorth)
public class LineWorth: NSManagedObject, Identifiable, Decodable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var descriptionText: String
    @NSManaged public var basePointsSource: String
    @NSManaged public var basePointsLow: NSNumber?
    @NSManaged public var basePointsMedium: NSNumber?
    @NSManaged public var basePointsHigh: NSNumber?
    @NSManaged public var area: String
    @NSManaged public var mountain: Mountain?
    
    enum CodingKeys: String, CodingKey {
        case id, name, area, basePoints
    }

    enum BasePointsKeys: String, CodingKey {
        case low, medium, high
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let managedObjectContext = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else {
            fatalError("Failed to decode LineWorth due to missing context.")
        }

        let entity = NSEntityDescription.entity(forEntityName: "LineWorth", in: managedObjectContext)!
        self.init(entity: entity, insertInto: managedObjectContext)

        self.id = UUID()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.area = try container.decode(String.self, forKey: .area)
        print("LineWorth decoded: \(self.name)")

        if let basePointsDict = try? container.nestedContainer(keyedBy: BasePointsKeys.self, forKey: .basePoints) {
            self.basePointsSource = "tiered"

            if let low = try basePointsDict.decodeIfPresent(Int.self, forKey: .low) {
                self.basePointsLow = NSNumber(value: low)
            }
            if let medium = try basePointsDict.decodeIfPresent(Int.self, forKey: .medium) {
                self.basePointsMedium = NSNumber(value: medium)
            }
            if let high = try basePointsDict.decodeIfPresent(Int.self, forKey: .high) {
                self.basePointsHigh = NSNumber(value: high)
            }
        } else if let basePointsInt = try? container.decode(Int.self, forKey: .basePoints) {
            self.basePointsSource = "flat"

            self.basePointsLow = NSNumber(value: basePointsInt)
            self.basePointsMedium = NSNumber(value: basePointsInt)
            self.basePointsHigh = NSNumber(value: basePointsInt)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .basePoints, in: container, debugDescription: "Invalid basePoints format")
        }

        // Optional: handle descriptionText if in JSON, otherwise skip
        self.descriptionText = "" // or remove if not used
    }
}

extension LineWorth {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LineWorth> {
        return NSFetchRequest<LineWorth>(entityName: "LineWorth")
    }

    var effectiveBasePoints: Int32 {
        if isFlatScored {
            return basePointsMedium?.int32Value ?? 0
        }

        let fallback = basePointsMedium?.int32Value ??
                       basePointsLow?.int32Value ??
                       basePointsHigh?.int32Value

        return fallback ?? 0
    }

    var isFlatScored: Bool {
        return basePointsSource == "flat"
    }
}
