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
    @NSManaged public var gameSession: GameSession?

    func playerName(in session: GameSession) -> String {
        guard let id = playerID else { return "Unknown Player" }
        return session.playersArray.first(where: { $0.id == id })?.name ?? "Unknown Player"
    }

    var proScore: Int {
        let linePoints = lineScore?.points ?? 0
        let trickPoints = trickBonusScoresArray.reduce(0) { $0 + $1.points }
        let ecpPoints = ecpScoresArray.reduce(0) { $0 + $1.points }
        let penaltyPoints = penaltyScoresArray.reduce(0) { $0 + $1.points } // Already negative

        return Int(Int32(linePoints) + trickPoints + ecpPoints + penaltyPoints)
    }

    var gnarScore: Int {
        let linePoints = abs(lineScore?.points ?? 0)
        let trickPoints = trickBonusScoresArray.reduce(0) { $0 + abs($1.points) }
        let ecpPoints = ecpScoresArray.reduce(0) { $0 + abs($1.points) }
        let penaltyPoints = penaltyScoresArray.reduce(0) { $0 + abs($1.points) }

        return Int(Int32(linePoints) + trickPoints + ecpPoints + penaltyPoints)
    }

    var trickBonusScoresArray: [TrickBonusScore] {
        (trickBonusScores?.allObjects as? [TrickBonusScore]) ?? []
    }

    var ecpScoresArray: [ECPScore] {
        (ecpScores?.allObjects as? [ECPScore]) ?? []
    }

    var penaltyScoresArray: [PenaltyScore] {
        (penaltyScores?.allObjects as? [PenaltyScore]) ?? []
    }
    
    func addLineScore(_ lineWorth: LineWorth, snowLevel: SnowLevel, context: NSManagedObjectContext) {
        let lineScore = LineScore.create(in: context, lineWorth: lineWorth, snowLevel: snowLevel.rawValue)
        lineScore.score = self
        self.lineScore = lineScore
    }

    func addTrickBonusScore(_ trickBonus: TrickBonus, context: NSManagedObjectContext) {
        let trickScore = TrickBonusScore(context: context)
        trickScore.id = UUID()
        trickScore.trickBonus = trickBonus
        trickScore.timestamp = Date()
        trickScore.points = trickBonus.points
        self.mutableSetValue(forKey: "trickBonusScores").add(trickScore)
    }

    func addECPScore(_ ecp: ECP, context: NSManagedObjectContext) {
        let ecpScore = ECPScore(context: context)
        ecpScore.id = UUID()
        ecpScore.ecp = ecp
        ecpScore.timestamp = Date()
        ecpScore.points = ecp.points
        self.mutableSetValue(forKey: "ecpScores").add(ecpScore)
    }

    func addPenaltyScore(_ penalty: Penalty, context: NSManagedObjectContext) {
        let penaltyScore = PenaltyScore(context: context)
        penaltyScore.id = UUID()
        penaltyScore.penalty = penalty
        penaltyScore.timestamp = Date()
        penaltyScore.points = penalty.points
        self.mutableSetValue(forKey: "penaltyScores").add(penaltyScore)
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
