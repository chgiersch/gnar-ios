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
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date?
    @NSManaged public var points: Int32
    @NSManaged public var verified: Bool
    
    @NSManaged public var penalty: Penalty?
    @NSManaged public var score: Score?
}

extension PenaltyScore {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PenaltyScore> {
        return NSFetchRequest<PenaltyScore>(entityName: "PenaltyScore")
    }
    
    static func create(in context: NSManagedObjectContext, penalty: Penalty, into score: Score) -> PenaltyScore {
        let penaltyScore = PenaltyScore(context: context)
        penaltyScore.id = UUID()
        penaltyScore.penalty = penalty
        penaltyScore.timestamp = Date()
        penaltyScore.points = penalty.points
        penaltyScore.verified = false
        penaltyScore.score = score
        return penaltyScore
    }
}
