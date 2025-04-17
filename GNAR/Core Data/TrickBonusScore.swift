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
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date?
    @NSManaged public var points: Int32
    @NSManaged public var verified: Bool
    
    @NSManaged public var trickBonus: TrickBonus?
    @NSManaged public var score: Score?
}

extension TrickBonusScore {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrickBonusScore> {
        return NSFetchRequest<TrickBonusScore>(entityName: "TrickBonusScore")
    }
    
    static func create(in context: NSManagedObjectContext, trickBonus: TrickBonus, into score: Score) -> TrickBonusScore {
        let trickScore = TrickBonusScore(context: context)
        trickScore.id = UUID()
        trickScore.trickBonus = trickBonus
        trickScore.timestamp = Date()
        trickScore.points = trickBonus.points
        trickScore.verified = false
        trickScore.score = score
        return trickScore
    }
}
