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
    
    convenience init(context: NSManagedObjectContext, player: Player, gameSession: GameSession) {
        print("📝 Score: Creating new score for \(player.name)")
        self.init(context: context)
        self.id = UUID()
        self.player = player
        self.creatorName = player.name
        self.gameSession = gameSession
        self.createdAt = Date()
        self.modifiedAt = self.createdAt
        self.isSoftDeleted = false
        self.syncedAt = nil
        self.gnarScore = 0
        self.heroScore = 0
        // Relationships are optional and will be initialized when needed
        self.lineScore = nil
        self.trickBonusScores = nil
        self.ecpScores = nil
        self.penaltyScores = nil
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        print("⚠️ Score: Created without convenience init - using defaults")
        // Initialize required properties
        self.id = UUID()
        self.createdAt = Date()
        self.modifiedAt = self.createdAt
        self.isSoftDeleted = false
        self.gnarScore = 0
        self.heroScore = 0
        // Relationships are optional and will be initialized when needed
        self.lineScore = nil
        self.trickBonusScores = nil
        self.ecpScores = nil
        self.penaltyScores = nil
    }
    
    // MARK: - Safe Array Accessors
    
    var trickBonusScoresArray: [TrickBonusScore] { scoresArray("trickBonusScores") }
    
    var ecpScoresArray: [ECPScore] { scoresArray("ecpScores") }
    
    var penaltyScoresArray: [PenaltyScore] { scoresArray("penaltyScores") }
    
    // Generic helper for safe array access
    private func scoresArray<T: NSManagedObject>(_ key: String) -> [T] {
        guard let set = value(forKey: key) as? NSSet else { return [] }
        return set.allObjects.compactMap { $0 as? T }
    }
    
    // MARK: - Relationship Management
    
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
    
    // MARK: - Score Calculation
    
    func calculateTotalScore() {
        // Get line score points
        let linePoints = lineScore?.points ?? 0
        print("📊 Score \(id) Calculation:")
        print("  Line Points: \(linePoints)")
        
        // Calculate trick bonus points
        let trickPoints = trickBonusScoresArray.reduce(0) { $0 + $1.points }
        print("  Trick Points: \(trickPoints)")
        
        // Calculate ECP points
        let ecpPoints = ecpScoresArray.reduce(0) { $0 + $1.points }
        print("  ECP Points: \(ecpPoints)")
        
        // Calculate penalty points (these should be subtracted)
        let penaltyPoints = penaltyScoresArray.reduce(0) { $0 + $1.points }
        print("  Penalty Points: \(penaltyPoints) (will be subtracted)")
        
        // Calculate total scores
        gnarScore = linePoints + trickPoints + ecpPoints + penaltyPoints
        print("  Total GNAR Score: \(gnarScore) = \(linePoints) + \(trickPoints) + \(ecpPoints) + \(penaltyPoints)")
        
        heroScore = abs(linePoints) + abs(trickPoints) + abs(ecpPoints) + abs(penaltyPoints)
        print("  Hero Score: \(heroScore)")
    }
}

extension Score {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Score> {
        return NSFetchRequest<Score>(entityName: "Score")
    }
    
    // MARK: - Helper Methods
    
    func softDelete() {
        isSoftDeleted = true
        modifiedAt = Date()
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
            existing.snowLevel = payload.snowLevel
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
            newLineScore.snowLevelRaw = payload.snowLevel.rawValue
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
