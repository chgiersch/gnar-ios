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
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
    @NSManaged public var syncedAt: Date?
    @NSManaged public var gnarScore: Int32
    @NSManaged public var heroScore: Int32
    @NSManaged public var isSoftDeleted: Bool
    
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
    
    // MARK: - Score Calculation
    
    func calculateTotalScore() {
        // Get line score points
        let linePoints = lineScore?.points ?? 0
        
        // Calculate trick bonus points
        let trickPoints = trickBonusScoresArray.reduce(0) { $0 + $1.points }
        
        // Calculate ECP points
        let ecpPoints = ecpScoresArray.reduce(0) { $0 + $1.points }
        
        // Calculate penalty points
        let penaltyPoints = penaltyScoresArray.reduce(0) { $0 + $1.points }
        
        // Calculate total scores
        gnarScore = linePoints + trickPoints + ecpPoints - penaltyPoints
        heroScore = abs(linePoints) + abs(trickPoints) + abs(ecpPoints) + abs(penaltyPoints)
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
        score.createdAt = Date()
        score.modifiedAt = score.createdAt
        score.syncedAt = nil
        score.isSoftDeleted = false
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
    
    func softDelete() {
        isSoftDeleted = true
        modifiedAt = Date()
    }
    
    func addToTrickBonusScores(_ trickScore: TrickBonusScore) {
        let items = mutableSetValue(forKey: "trickBonusScores")
        items.add(trickScore)
        calculateTotalScore()
    }
    
    func removeFromTrickBonusScores(_ trickScore: TrickBonusScore) {
        let items = mutableSetValue(forKey: "trickBonusScores")
        items.remove(trickScore)
        calculateTotalScore()
    }
    
    func addToEcpScores(_ ecpScore: ECPScore) {
        let items = mutableSetValue(forKey: "ecpScores")
        items.add(ecpScore)
        calculateTotalScore()
    }
    
    func removeFromEcpScores(_ ecpScore: ECPScore) {
        let items = mutableSetValue(forKey: "ecpScores")
        items.remove(ecpScore)
        calculateTotalScore()
    }
    
    func addToPenaltyScores(_ penaltyScore: PenaltyScore) {
        let items = mutableSetValue(forKey: "penaltyScores")
        items.add(penaltyScore)
        calculateTotalScore()
    }
    
    func removeFromPenaltyScores(_ penaltyScore: PenaltyScore) {
        let items = mutableSetValue(forKey: "penaltyScores")
        items.remove(penaltyScore)
        calculateTotalScore()
    }
    
    func addLineScore(_ lineWorth: LineWorth, snowLevel: SnowLevel, in context: NSManagedObjectContext) {
        let lineScore = LineScore.create(in: context, lineWorth: lineWorth, snowLevel: snowLevel)
        lineScore.score = self
        self.lineScore = lineScore
        calculateTotalScore()
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


extension Score {
    func toSyncPayload() -> ScoreSyncPayload? {
        guard let player = player else {
            print("⚠️ Score \(id) has no associated Player")
            return nil
        }
        
        return ScoreSyncPayload(
            id: id,
            playerId: player.id,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            isSoftDeleted: isSoftDeleted,
            gnarScore: gnarScore,
            heroScore: heroScore,
            lineScoreId: lineScore?.id,
            trickBonusScoreIds: trickBonusScoresArray.map { $0.id },
            ecpScoreIds: ecpScoresArray.map { $0.id },
            penaltyScoreIds: penaltyScoresArray.map { $0.id }
        )
    }
    
    /// Merges the incoming sync payload into Core Data.
    /// - Parameters:
    ///   - payload: The `ScoreSyncPayload` received via Multipeer.
    ///   - context: The Core Data context to apply the change in.
    /// - Returns: The updated or created `Score` object.
    static func merge(from payload: ScoreSyncPayload, into context: NSManagedObjectContext) throws -> Score {
        // Try to fetch the existing Score ID
        let fetchRequest: NSFetchRequest<Score> = Score.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", payload.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        let existingScore = try context.fetch(fetchRequest).first
        
        if let score = existingScore {
            // Existing score found - check which is newer
            if payload.modifiedAt > score.modifiedAt {
                print("🔄 Updating Score \(score.id)")
                score.applyPayload(payload)
            } else {
                print("⚠️ Incoming payload for Score \(score.id) is older — ignoring")
            }
            return score
        } else {
            // No existing score — create new
            print("🆕 Creating new Score \(payload.id)")
            let newScore = Score(context: context)
            newScore.id = payload.id
            newScore.createdAt = payload.createdAt
            newScore.applyPayload(payload)
            return newScore
        }
    }
     
    /// Applies a sync payload onto an existing Score object.
    /// - Parameter payload: The sync payload to apply.
    func applyPayload(_ payload: ScoreSyncPayload) {
        self.modifiedAt = payload.modifiedAt
        self.isSoftDeleted = payload.isSoftDeleted
        self.gnarScore = payload.gnarScore
        self.heroScore = payload.heroScore
        
        // TODO: Update lineScore, trickBonusScores, ecpScores, penaltyScores
    }
}
