//
//  Models.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//

import Foundation

struct ScoreSummary: Identifiable {
    let id: UUID
    let lineName: String?
    let snowLevel: SnowLevel?
    let points: Int
}

struct GameSessionPreview: Identifiable {
    let id: UUID
    let mountainName: String
    let date: Date
    let playerCount: Int
    let playerNames: [String]

    init?(from session: GameSession) {
        guard
            let id = session.id,
            let date = session.startDate
        else {
            return nil
        }

        self.id = id
        
        guard session.mountainName.isEmpty == false else {
            print("❌ Skipping GameSession with empty mountainName: \(session.id?.uuidString ?? "unknown")")
            return nil
        }
        self.mountainName = session.mountainName

        self.date = date

        if let players = session.players as? Set<Player> {
            self.playerNames = players.map { $0.name }
            self.playerCount = players.count
        } else {
            self.playerNames = []
            self.playerCount = 0
        }
    }
}

struct MountainPreview: Identifiable, Equatable {
    let id: String
    let name: String
    let isGlobal: Bool
}
