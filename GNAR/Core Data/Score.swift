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
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date?
    @NSManaged public var gnarScore: Int32
    @NSManaged public var heroScore: Int32
    
    @NSManaged public var lineScore: LineScore?
    @NSManaged public var trickBonusScores: NSSet?
    @NSManaged public var ecpScores: NSSet?
    @NSManaged public var penaltyScores: NSSet?
    @NSManaged public var gameSession: GameSession?
    @NSManaged public var player: Player?

    var playerName: String {
        return player?.name ?? "Unknown Player"
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
}

extension Score {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Score> {
        return NSFetchRequest<Score>(entityName: "Score")
    }
    
    // MARK: - Factory Methods
    
    static func create(
        in context: NSManagedObjectContext,
        player: Player,
        lineScore: LineScore,
        trickBonuses: [TrickBonus],
        ecps: [ECP],
        penalties: [Penalty],
        into gameSession: GameSession
    ) -> Score {
        let score = Score(context: context)
        score.id = UUID()
        score.timestamp = Date()
        score.player = player
        score.lineScore = lineScore
        score.gameSession = gameSession
        
        // Create and calculate trick bonus scores
        var totalTrickPoints: Int32 = 0
        for trick in trickBonuses {
            let trickScore = TrickBonusScore.create(in: context, trickBonus: trick, into: score)
            score.addToTrickBonusScores(trickScore)
            totalTrickPoints += trickScore.points
        }
        
        // Create and calculate ECP scores
        var totalECPPoints: Int32 = 0
        for ecp in ecps {
            let ecpScore = ECPScore.create(in: context, ecp: ecp, into: score)
            score.addToEcpScores(ecpScore)
            totalECPPoints += ecpScore.points
        }
        
        // Create and calculate penalty scores
        var totalPenaltyPoints: Int32 = 0
        for penalty in penalties {
            let penaltyScore = PenaltyScore.create(in: context, penalty: penalty, into: score)
            score.addToPenaltyScores(penaltyScore)
            totalPenaltyPoints += penaltyScore.points
        }
        
        // Calculate and store final scores
        let linePoints = lineScore.points
        score.gnarScore = linePoints + totalTrickPoints + totalECPPoints - totalPenaltyPoints
        score.heroScore = abs(linePoints) + abs(totalTrickPoints) + abs(totalECPPoints) + abs(totalPenaltyPoints)
        
        return score
    }
    
    // MARK: - Helper Methods
    
    func addToTrickBonusScores(_ trickScore: TrickBonusScore) {
        let items = mutableSetValue(forKey: "trickBonusScores")
        items.add(trickScore)
    }
    
    func removeFromTrickBonusScores(_ trickScore: TrickBonusScore) {
        let items = mutableSetValue(forKey: "trickBonusScores")
        items.remove(trickScore)
    }
    
    func addToEcpScores(_ ecpScore: ECPScore) {
        let items = mutableSetValue(forKey: "ecpScores")
        items.add(ecpScore)
    }
    
    func removeFromEcpScores(_ ecpScore: ECPScore) {
        let items = mutableSetValue(forKey: "ecpScores")
        items.remove(ecpScore)
    }
    
    func addToPenaltyScores(_ penaltyScore: PenaltyScore) {
        let items = mutableSetValue(forKey: "penaltyScores")
        items.add(penaltyScore)
    }
    
    func removeFromPenaltyScores(_ penaltyScore: PenaltyScore) {
        let items = mutableSetValue(forKey: "penaltyScores")
        items.remove(penaltyScore)
    }
    
    func addLineScore(_ lineWorth: LineWorth, snowLevel: SnowLevel, in context: NSManagedObjectContext) {
        let lineScore = LineScore.create(in: context, lineWorth: lineWorth, snowLevel: snowLevel)
        lineScore.score = self
        self.lineScore = lineScore
    }
    
    func addTrickBonusScore(_ trickBonus: TrickBonus, in context: NSManagedObjectContext) {
        let trickScore = TrickBonusScore(context: context)
        trickScore.id = UUID()
        trickScore.trickBonus = trickBonus
        trickScore.timestamp = Date()
        trickScore.points = trickBonus.points
        self.addToTrickBonusScores(trickScore)
    }
    
    func addECPScore(_ ecp: ECP, in context: NSManagedObjectContext) {
        let ecpScore = ECPScore(context: context)
        ecpScore.id = UUID()
        ecpScore.ecp = ecp
        ecpScore.timestamp = Date()
        ecpScore.points = ecp.points
        self.addToEcpScores(ecpScore)
    }
    
    func addPenaltyScore(_ penalty: Penalty, in context: NSManagedObjectContext) {
        let penaltyScore = PenaltyScore(context: context)
        penaltyScore.id = UUID()
        penaltyScore.penalty = penalty
        penaltyScore.timestamp = Date()
        penaltyScore.points = penalty.points
        self.addToPenaltyScores(penaltyScore)
    }
}
