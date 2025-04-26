//
//  Models.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//

import Foundation

struct GameSessionPreview: Identifiable, Equatable {
    let id: String
    let mountainName: String
    let startDate: Date
    let playerIds: [UUID]
    let playerNames: [String]
    let playerCount: Int
    
    init(id: String = UUID().uuidString, 
         mountain: Mountain, 
         playerCount: Int = 0, 
         startDate: Date = Date()) {
        self.id = id
        self.mountainName = mountain.name
        self.startDate = startDate
        self.playerCount = playerCount
        self.playerIds = []
        self.playerNames = []
    }
    
    init(from session: GameSession) {
        self.id = session.id.uuidString
        self.mountainName = session.mountain.name
        self.startDate = session.startDate ?? Date()
        self.playerIds = session.playersArray.map { $0.id }
        self.playerNames = session.playersArray.map { $0.name ?? "Unknown Player" }
        self.playerCount = session.playersArray.count
    }
}

struct MountainPreview: Identifiable, Equatable {
    let id: String
    let name: String
    let isGlobal: Bool
    
    /// Initialize a mountain preview from a Mountain entity
    init(mountain: Mountain) {
        self.id = mountain.id
        self.name = mountain.name == "Global" ? "Free Range" : (mountain.name)
        self.isGlobal = mountain.isGlobal
    }
}

