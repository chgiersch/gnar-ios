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
    @NSManaged public var id: UUID
    @NSManaged public var idDescriptor: String?
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
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else {
            fatalError("❌ Failed to decode TrickBonus due to missing Core Data context")
        }

        let entity = NSEntityDescription.entity(forEntityName: "TrickBonus", in: context)!
        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.idDescriptor = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.points = Int32(try container.decode(Int.self, forKey: .points))

        self.descriptionText = ""
        self.requiresVerification = false
        self.category = nil
    }
}

extension TrickBonus {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrickBonus> {
        return NSFetchRequest<TrickBonus>(entityName: "TrickBonus")
    }
}
