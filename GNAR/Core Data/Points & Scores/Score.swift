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
    @NSManaged public var creatorName: String
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
        into gameSession: GameSession,
        creatorName: String
    ) -> Score {
        let score = Score(context: context)
        score.id = UUID()
        score.creatorName = player.name
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

    // MARK: - MultipeerConnectivity (MPC) Sync

    func toSyncPayload() -> ScoreSyncPayload? {
        guard let player = player else {
            print("⚠️ Score \(id) has no associated Player")
            return nil
        }
        
        guard let gameSession = gameSession else {
            print("⚠️ Score \(id) has no associated GameSession")
            return nil
        }
        
        return ScoreSyncPayload(
            id: id,
            playerId: player.id,
            gameSessionId: gameSession.id,
            creatorName: creatorName,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            isSoftDeleted: isSoftDeleted,
            gnarScore: gnarScore,
            heroScore: heroScore,
            lineScore: lineScore?.toPayload(),
            trickBonusScores: trickBonusScoresArray.map { $0.toPayload() },
            ecpScores: ecpScoresArray.map { $0.toPayload() },
            penaltyScores: penaltyScoresArray.map { $0.toPayload() }
        )
    }
    
    /// Merges the incoming sync payload into Core Data.
    /// - Parameters:
    ///   - payload: The `ScoreSyncPayload` received via Multipeer.
    ///   - context: The Core Data context to apply the change in.
    /// - Returns: The updated or created `Score` object.
    static func merge(from payload: ScoreSyncPayload, into context: NSManagedObjectContext, resolver: SyncRelationshipResolver) throws -> Score {
        // Try to fetch the existing Score ID
        let fetchRequest: NSFetchRequest<Score> = Score.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", payload.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        let existingScore = try context.fetch(fetchRequest).first
        
        if let existingScore = existingScore {
            // Existing score found - check which is newer
            if payload.modifiedAt > existingScore.modifiedAt {
                print("🔄 Updating Score \(existingScore.id)")
                existingScore.applyPayload(payload, resolver: resolver)
            } else {
                print("⚠️ Incoming payload for Score \(existingScore.id) is older — ignoring")
            }
            return existingScore
        } else {
            // No score with that ID found - create a new one
            print("➕ Creating new Score from payload \(payload.id)")
            let newScore = Score(context: context)
            newScore.id = payload.id
            newScore.createdAt = payload.createdAt
            newScore.applyPayload(payload, resolver: resolver)
            return newScore
        }
    }
     
    /// Applies a sync payload onto an existing Score object.
    /// - Parameter payload: The sync payload to apply.
    func applyPayload(_ payload: ScoreSyncPayload, resolver: SyncRelationshipResolver) {
        self.creatorName = payload.creatorName
        self.modifiedAt = payload.modifiedAt
        self.isSoftDeleted = payload.isSoftDeleted
        self.gnarScore = payload.gnarScore
        self.heroScore = payload.heroScore
        self.syncedAt = Date()  // Mark as synced on successful application
        
        // Resolve Relationships via resolver
        self.player = resolver.resolvePlayer(with: payload.playerId)
        self.gameSession = resolver.resolveGameSession(with: payload.gameSessionId)
        
        // Handle LineScore relationship
        if let lineScorePayload = payload.lineScore {
            self.lineScore = resolver.resolveOrCreateLineScore(from: lineScorePayload)
        }
        
        // Handle TrickBonusScores
        let trickScores = resolver.resolveOrCreateTrickBonusScores(from: payload.trickBonusScores)
        let trickSet = NSMutableSet(array: trickScores)
        self.trickBonusScores = trickSet
        
        // Handle ECPScores
        let ecpScores = resolver.resolveOrCreateECPScores(from: payload.ecpScores)
        let ecpSet = NSMutableSet(array: ecpScores)
        self.ecpScores = ecpSet
        
        // Handle PenaltyScores
        let penaltyScores = resolver.resolveOrCreatePenaltyScores(from: payload.penaltyScores)
        let penaltySet = NSMutableSet(array: penaltyScores)
        self.penaltyScores = penaltySet
        
        calculateTotalScore()
    }
}

struct SyncRelationshipResolver {
    let context: NSManagedObjectContext
    
    // MARK: - LineScore
    
    func resolveOrCreateLineScore(from payload: LineScorePayload) -> LineScore {
        let request: NSFetchRequest<LineScore> = LineScore.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", payload.id as CVarArg)
        request.fetchLimit = 1
        
        if let existing = try? context.fetch(request).first {
            // Update existing LineScore
            existing.points = payload.points
            existing.snowLevelEnum = payload.snowLevel
            // Find LineWorth if needed
            if existing.lineWorth == nil {
                existing.lineWorth = findLineWorthById(payload.lineWorthId)
            }
            return existing
        } else {
            // Create new LineScore
            let newLineScore = LineScore(context: context)
            newLineScore.id = payload.id
            newLineScore.points = payload.points
            newLineScore.snowLevelEnum = payload.snowLevel
            newLineScore.lineWorth = findLineWorthById(payload.lineWorthId)
            return newLineScore
        }
    }
    
    func findLineWorthById(_ id: UUID) -> LineWorth? {
        let request: NSFetchRequest<LineWorth> = LineWorth.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    // MARK: - TrickBonusScore
    
    func resolveOrCreateTrickBonusScores(from payloads: [TrickBonusScorePayload]) -> [TrickBonusScore] {
        return payloads.compactMap { payload in
            let request: NSFetchRequest<TrickBonusScore> = TrickBonusScore.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", payload.id as CVarArg)
            request.fetchLimit = 1
            
            if let existing = try? context.fetch(request).first {
                // Update existing
                existing.points = payload.points
                existing.timestamp = payload.timestamp
                if existing.trickBonus == nil {
                    existing.trickBonus = findTrickBonusById(payload.trickBonusId)
                }
                return existing
            } else {
                // Create new
                let newScore = TrickBonusScore(context: context)
                newScore.id = payload.id
                newScore.points = payload.points
                newScore.timestamp = payload.timestamp
                newScore.trickBonus = findTrickBonusById(payload.trickBonusId)
                return newScore
            }
        }
    }
    
    func findTrickBonusById(_ id: UUID) -> TrickBonus? {
        let request: NSFetchRequest<TrickBonus> = TrickBonus.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    // MARK: - ECPScores
    
    func resolveOrCreateECPScores(from payloads: [ECPSyncPayload]) -> [ECPScore] {
        return payloads.compactMap { payload in
            let request: NSFetchRequest<ECPScore> = ECPScore.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", payload.id as CVarArg)
            request.fetchLimit = 1

            if let existing = try? context.fetch(request).first {
                // Update existing
                existing.points = payload.points
                existing.timestamp = payload.timestamp
                if existing.ecp == nil {
                    existing.ecp = findECPById(payload.ecpId)
                }
                return existing
            } else {
                // Create new
                let newScore = ECPScore(context: context)
                newScore.id = payload.id
                newScore.points = payload.points
                newScore.timestamp = payload.timestamp
                newScore.ecp = findECPById(payload.ecpId)
                return newScore
            }
        }
    }
    
    func findECPById(_ id: UUID) -> ECP? {
        let request: NSFetchRequest<ECP> = ECP.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    // MARK: - PenaltyScores
    
    func resolveOrCreatePenaltyScores(from payloads: [PenaltySyncPayload]) -> [PenaltyScore] {
        return payloads.compactMap { payload in
            let request: NSFetchRequest<PenaltyScore> = PenaltyScore.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", payload.id as CVarArg)
            request.fetchLimit = 1

            if let existing = try? context.fetch(request).first {
                // Update existing
                existing.points = payload.points
                existing.timestamp = payload.timestamp
                if existing.penalty == nil {
                    existing.penalty = findPenaltyById(payload.penaltyId)
                }
                return existing
            } else {
                // Create new
                let newScore = PenaltyScore(context: context)
                newScore.id = payload.id
                newScore.points = payload.points
                newScore.timestamp = payload.timestamp
                newScore.penalty = findPenaltyById(payload.penaltyId)
                return newScore
            }
        }
    }
    
    func findPenaltyById(_ id: UUID) -> Penalty? {
        let request: NSFetchRequest<Penalty> = Penalty.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    // MARK: - Player and GameSession

    func resolvePlayer(with id: UUID) -> Player? {
        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    func resolveGameSession(with id: UUID) -> GameSession? {
        let request: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

}
