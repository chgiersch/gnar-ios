//
//  TrickBonus.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import Foundation
import CoreData

@objc(TrickBonus)
public class TrickBonus: NSManagedObject, Identifiable, Decodable {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var descriptionText: String
    @NSManaged public var points: Int32
    @NSManaged public var requiresVerification: Bool
    @NSManaged public var category: String?
    @NSManaged public var mountain: Mountain?
    
    enum CodingKeys: String, CodingKey {
        case id, name, points
    }

    required convenience public init(from decoder: Decoder) throws {
        // Extract Core Data context
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else {
            fatalError("❌ Failed to decode TrickBonus due to missing Core Data context")
        }

        let entity = NSEntityDescription.entity(forEntityName: "TrickBonus", in: context)!
        self.init(entity: entity, insertInto: context)

        // Decode fields
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.points = Int32(try container.decode(Int.self, forKey: .points))

        // Set defaults for non-JSON fields
        self.descriptionText = ""
        self.requiresVerification = false
        self.category = nil
        // self.mountain will be assigned in Mountain.swift
    }
}

// MARK: - Fetch Request
extension TrickBonus {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrickBonus> {
        return NSFetchRequest<TrickBonus>(entityName: "TrickBonus")
    }
}
