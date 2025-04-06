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
    @NSManaged public var id: UUID?
    @NSManaged public var name: String
    @NSManaged public var gnarScore: Int32
    @NSManaged public var proScore: Int32
    @NSManaged public var gameSessions: NSSet?
}

extension Player {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }
    
    var gameSessionsArray: [GameSession] {
        let set = gameSessions as? Set<GameSession> ?? []
        return Array(set)
    }
    
    @objc(addGameSessionsObject:)
    @NSManaged public func addToGameSessions(_ value: GameSession)
    
    @objc(removeGameSessionsObject:)
    @NSManaged public func removeFromGameSessions(_ value: GameSession)
    
    @objc(addGameSessions:)
    @NSManaged public func addToGameSessions(_ values: NSSet)
    
    @objc(removeGameSessions:)
    @NSManaged public func removeFromGameSessions(_ values: NSSet)
}
