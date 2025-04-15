//
//  Penalty.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import Foundation
import CoreData

@objc(Penalty)
public class Penalty: NSManagedObject, Identifiable, Decodable {
    @NSManaged public var id: UUID
    @NSManaged public var idDescriptor: String?
    @NSManaged public var name: String
    @NSManaged public var descriptionText: String
    @NSManaged public var points: Int32
    @NSManaged public var abbreviation: String
    @NSManaged public var mountain: Mountain?
    
    enum CodingKeys: String, CodingKey {
        case id, name, descriptionText, points, abbreviation
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let managedObjectContext = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else {
            fatalError("❌ Missing Core Data context while decoding Penalty")
        }

        let entity = NSEntityDescription.entity(forEntityName: "Penalty", in: managedObjectContext)!
        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.idDescriptor = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.descriptionText = try container.decode(String.self, forKey: .descriptionText)
        self.points = Int32(try container.decode(Int.self, forKey: .points))
        self.abbreviation = try container.decode(String.self, forKey: .abbreviation)
    }
}

extension Penalty {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Penalty> {
        return NSFetchRequest<Penalty>(entityName: "Penalty")
    }
}
