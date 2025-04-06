//
//  TrickBonusScore.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import Foundation
import CoreData

@objc(TrickBonusScore)
public class TrickBonusScore: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var points: Int32
    @NSManaged public var timestamp: Date?
    
    // Relationships
    @NSManaged public var trickBonus: TrickBonus?
    @NSManaged public var parentScore: Score?
}

extension TrickBonusScore {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrickBonusScore> {
        return NSFetchRequest<TrickBonusScore>(entityName: "TrickBonusScore")
    }

    static func create(in context: NSManagedObjectContext, trickBonus: TrickBonus, parentScore: Score) -> TrickBonusScore {
        let score = TrickBonusScore(context: context)
        score.id = UUID()
        score.timestamp = Date()
        score.points = trickBonus.points
        score.trickBonus = trickBonus
        score.parentScore = parentScore
        return score
    }
}
