//
//  Player.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import Foundation
import CoreData

@objc(Player)
public class Player: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var gameSessions: NSSet?
    @NSManaged public var scores: NSSet?
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
        self.gameSessions = NSSet()
        self.scores = NSSet()
    }
}

extension Player {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }
    
    var gameSessionsArray: [GameSession] {
        let set = gameSessions as? Set<GameSession> ?? []
        return Array(set)
    }
    
    var scoresArray: [Score] {
        let set = scores as? Set<Score> ?? []
        return Array(set)
    }
    
    var allTimeGnarScore: Int32 {
        gameSessionsArray.reduce(0) { total, session in
            total + session.scoresArray
                .filter { $0.player?.id == self.id }
                .reduce(0) { $0 + $1.gnarScore }
        }
    }
    
    var allTimeProScore: Int32 {
        gameSessionsArray.reduce(0) { total, session in
            total + session.scoresArray
                .filter { $0.player?.id == self.id }
                .reduce(0) { $0 + $1.proScore }
        }
    }
    
    @objc(addGameSessionsObject:)
    @NSManaged public func addToGameSessions(_ value: GameSession)
    
    @objc(removeGameSessionsObject:)
    @NSManaged public func removeFromGameSessions(_ value: GameSession)
    
    @objc(addGameSessions:)
    @NSManaged public func addToGameSessions(_ values: NSSet)
    
    @objc(removeGameSessions:)
    @NSManaged public func removeFromGameSessions(_ values: NSSet)
    
    @objc(addScoresObject:)
    @NSManaged public func addToScores(_ value: Score)
    
    @objc(removeScoresObject:)
    @NSManaged public func removeFromScores(_ value: Score)
    
    @objc(addScores:)
    @NSManaged public func addToScores(_ values: NSSet)
    
    @objc(removeScores:)
    @NSManaged public func removeFromScores(_ values: NSSet)
}
