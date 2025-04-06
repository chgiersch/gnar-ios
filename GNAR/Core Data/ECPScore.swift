//
//  ECPScore.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import Foundation
import CoreData

@objc(ECPScore)
public class ECPScore: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var points: Int32
    @NSManaged public var timestamp: Date?

    // Relationships
    @NSManaged public var ecp: ECP?
    @NSManaged public var parentScore: Score?
}

extension ECPScore {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ECPScore> {
        return NSFetchRequest<ECPScore>(entityName: "ECPScore")
    }

    static func create(in context: NSManagedObjectContext, ecp: ECP, parentScore: Score) -> ECPScore {
        let score = ECPScore(context: context)
        score.id = UUID()
        score.timestamp = Date()
        score.points = ecp.points
        score.ecp = ecp
        score.parentScore = parentScore
        return score
    }
}
