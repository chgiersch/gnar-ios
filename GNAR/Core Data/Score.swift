//
//  Score.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import Foundation
import CoreData

@objc(Score)
public class Score: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var playerID: UUID?
    @NSManaged public var timestamp: Date?
    
    @NSManaged public var lineScore: LineScore?
    @NSManaged public var trickBonusScores: NSSet?
    @NSManaged public var ecpScores: NSSet?
    @NSManaged public var penaltyScores: NSSet?

    var proScore: Int {
        print("✅ Using custom Score class")
        let linePoints = (lineScore)?.points ?? 0
        let trickPoints = trickBonusScoresArray.reduce(0) { $0 + $1.points }
        let ecpPoints = ecpScoresArray.reduce(0) { $0 + $1.points }
        let penaltyPoints = penaltyScoresArray.reduce(0) { $0 + $1.points }
        return Int(Int32(linePoints) + trickPoints + ecpPoints + penaltyPoints)
    }

    var trickBonusScoresArray: [TrickBonusScore] {
        (trickBonusScores as? Set<TrickBonusScore>)?.sorted(by: { $0.timestamp ?? Date.distantPast < $1.timestamp ?? Date.distantPast }) ?? []
    }

    var ecpScoresArray: [ECPScore] {
        (ecpScores as? Set<ECPScore>)?.sorted(by: { $0.timestamp ?? Date.distantPast < $1.timestamp ?? Date.distantPast }) ?? []
    }

    var penaltyScoresArray: [PenaltyScore] {
        (penaltyScores as? Set<PenaltyScore>)?.sorted(by: { $0.timestamp ?? Date.distantPast < $1.timestamp ?? Date.distantPast }) ?? []
    }
}

extension Score {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Score> {
        return NSFetchRequest<Score>(entityName: "Score")
    }
    
    static func calculateProScore(from score: Score) -> Int {
        let linePoints = score.lineScore?.points ?? 0
        let trickPoints = (score.trickBonusScores as? Set<TrickBonusScore>)?.reduce(0) { $0 + $1.points } ?? 0
        let ecpPoints = (score.ecpScores as? Set<ECPScore>)?.reduce(0) { $0 + $1.points } ?? 0
        let penaltyPoints = (score.penaltyScores as? Set<PenaltyScore>)?.reduce(0) { $0 + $1.points } ?? 0
        return Int(Int32(linePoints) + trickPoints + ecpPoints + penaltyPoints)
    }
}
