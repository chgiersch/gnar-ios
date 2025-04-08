//
//  GameSession.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import Foundation
import CoreData

@objc(GameSession)
public class GameSession: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var mountainName: String
    @NSManaged public var startDate: Date?
    @NSManaged public var players: NSSet?
    @NSManaged public var scores: NSSet?

    public var playersArray: [Player] {
        let set = players as? Set<Player> ?? []
        return Array(set)
    }

    public var scoresArray: [Score] {
        let set = scores as? Set<Score> ?? []
        return Array(set)
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
        self.startDate = Date()
        self.players = NSSet()
        self.scores = NSSet()
        print("🆕 New GameSession created with ID: \(self.id?.uuidString ?? "unknown")")
    }
}

extension GameSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameSession> {
        return NSFetchRequest<GameSession>(entityName: "GameSession")
    }

    @objc(addPlayersObject:)
    @NSManaged public func addToPlayers(_ value: Player)

    @objc(removePlayersObject:)
    @NSManaged public func removeFromPlayers(_ value: Player)

    @objc(addPlayers:)
    @NSManaged public func addToPlayers(_ values: NSSet)

    @objc(removePlayers:)
    @NSManaged public func removeFromPlayers(_ values: NSSet)

    @objc(addScoresObject:)
    @NSManaged public func addToScores(_ value: Score)

    @objc(removeScoresObject:)
    @NSManaged public func removeFromScores(_ value: Score)

    @objc(addScores:)
    @NSManaged public func addToScores(_ values: NSSet)

    @objc(removeScores:)
    @NSManaged public func removeFromScores(_ values: NSSet)
}
