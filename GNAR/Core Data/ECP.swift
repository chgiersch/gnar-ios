//
//  ECP.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import Foundation
import CoreData

@objc(ECP)
public class ECP: NSManagedObject, Identifiable, Decodable {
    @NSManaged public var id: UUID
    @NSManaged public var idDescriptor: String?
    @NSManaged public var name: String
    @NSManaged public var descriptionText: String
    @NSManaged public var points: Int32
    @NSManaged public var frequency: String
    @NSManaged public var abbreviation: String
    @NSManaged public var mountain: Mountain?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case descriptionText
        case points
        case frequency
        case abbreviation
        case mountain
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contextKey = CodingUserInfoKey.context,
              let managedObjectContext = decoder.userInfo[contextKey] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "ECP", in: managedObjectContext) else {
            fatalError("Failed to decode ECP")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.idDescriptor = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.descriptionText = try container.decode(String.self, forKey: .descriptionText)
        self.points = try container.decode(Int32.self, forKey: .points)
        self.frequency = try container.decode(String.self, forKey: .frequency)
        self.abbreviation = try container.decode(String.self, forKey: .abbreviation)
        self.mountain = try container.decodeIfPresent(Mountain.self, forKey: .mountain)
        print("ECP decoded: \(self.name)")
    }
}

extension ECP {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ECP> {
        return NSFetchRequest<ECP>(entityName: "ECP")
    }
    
    var frequencyType: FrequencyType {
        FrequencyType(rawValue: frequency.lowercased()) ?? .daily
    }
}

enum FrequencyType: String {
    case unlimited
    case daily
    case yearly
}
