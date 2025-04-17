//
//  Models.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//

import Foundation

struct GameSessionPreview: Identifiable, Equatable {
    let id: UUID
    let mountainName: String
    let startDate: Date
    let playerCount: Int
    
    init(id: UUID = UUID(), 
         mountainName: String = "Unknown Mountain", 
         playerCount: Int = 0, 
         startDate: Date = Date()) {
        self.id = id
        self.mountainName = mountainName
        self.startDate = startDate
        self.playerCount = playerCount
    }
    
    init(from session: GameSession) {
        self.id = session.id
        self.mountainName = session.mountainName.isEmpty ? "Unknown Mountain" : session.mountainName
        self.startDate = session.startDate ?? Date()
        self.playerCount = (session.players as? Set<Player>)?.count ?? 0
    }
}

struct MountainPreview: Identifiable, Equatable {
    let id: String
    let name: String
    let isGlobal: Bool
}
