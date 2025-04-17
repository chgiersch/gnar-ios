//
//  Mountain.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import Foundation
import CoreData

@objc(Mountain)
public class Mountain: NSManagedObject, Identifiable, Decodable {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var lineWorths: NSSet?
    @NSManaged public var ecps: NSSet?
    @NSManaged public var trickBonuses: NSSet?
    @NSManaged public var penalties: NSSet?
    @NSManaged public var isGlobal: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case lineWorths
        case ecps
        case penalties
        case trickBonuses
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let managedObjectContext = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else {
            fatalError("Failed to decode Mountain due to missing context.")
        }

        let entity = NSEntityDescription.entity(forEntityName: "Mountain", in: managedObjectContext)!
        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        print("Mountain decoded: \(self.name)")

        // LineWorths
        let lineWorths = try container.decodeIfPresent(Set<LineWorth>.self, forKey: .lineWorths) ?? []
        for lineWorth in lineWorths {
            lineWorth.mountain = self
        }
        self.lineWorths = lineWorths as NSSet

        // ECPs
        let ecps = try container.decodeIfPresent(Set<ECP>.self, forKey: .ecps) ?? []
        for ecp in ecps {
            ecp.mountain = self
        }
        self.ecps = ecps as NSSet

        // Penalties
        if let penalties = try container.decodeIfPresent(Set<Penalty>.self, forKey: .penalties) {
            for penalty in penalties {
                penalty.mountain = self
            }
            self.penalties = penalties as NSSet
        }

        // TrickBonuses
        if let trickBonuses = try container.decodeIfPresent(Set<TrickBonus>.self, forKey: .trickBonuses) {
            for trick in trickBonuses {
                trick.mountain = self
            }
            self.trickBonuses = trickBonuses as NSSet
        }
    }
}

extension Mountain {
    var lineWorthsArray: [LineWorth] {
        let set = lineWorths as? Set<LineWorth> ?? []
        return Array(set)
    }
    
    var trickBonusesArray: [TrickBonus] {
        let set = trickBonuses as? Set<TrickBonus> ?? []
        return Array(set)
    }

    var penaltiesArray: [Penalty] {
        let set = penalties as? Set<Penalty> ?? []
        return Array(set)
    }
    
    var ecpsArray: [ECP] {
        let set = ecps as? Set<ECP> ?? []
        return Array(set)
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mountain> {
        return NSFetchRequest<Mountain>(entityName: "Mountain")
    }
}

extension Mountain {
    @objc(addTrickBonusesObject:)
    @NSManaged public func addToTrickBonuses(_ value: TrickBonus)
    
    @objc(removeTrickBonusesObject:)
    @NSManaged public func removeFromTrickBonuses(_ value: TrickBonus)
    
    @objc(addTrickBonuses:)
    @NSManaged public func addToTrickBonuses(_ values: NSSet)
    
    @objc(removeTrickBonuses:)
    @NSManaged public func removeFromTrickBonuses(_ values: NSSet)

    @objc(addPenaltiesObject:)
    @NSManaged public func addToPenalties(_ value: Penalty)
    
    @objc(removePenaltiesObject:)
    @NSManaged public func removeFromPenalties(_ value: Penalty)
    
    @objc(addPenalties:)
    @NSManaged public func addToPenalties(_ values: NSSet)
    
    @objc(removePenalties:)
    @NSManaged public func removeFromPenalties(_ values: NSSet)
}
