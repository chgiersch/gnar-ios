//
//  PenaltyScore.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import Foundation
import CoreData

@objc(PenaltyScore)
public class PenaltyScore: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var points: Int32
    @NSManaged public var timestamp: Date?

    // Relationships
    @NSManaged public var penalty: Penalty?
    @NSManaged public var parentScore: Score?
}

extension PenaltyScore {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PenaltyScore> {
        return NSFetchRequest<PenaltyScore>(entityName: "PenaltyScore")
    }

    static func create(in context: NSManagedObjectContext, penalty: Penalty, parentScore: Score) -> PenaltyScore {
        let score = PenaltyScore(context: context)
        score.id = UUID()
        score.timestamp = Date()
        score.points = penalty.points
        score.penalty = penalty
        score.parentScore = parentScore
        return score
    }
}
