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

struct GameSessionPreview: Identifiable, Equatable {
    let id: UUID
    let mountainName: String
    let date: Date
    let playerCount: Int

    init?(from session: GameSession) {
        guard
            let id = session.id,
            let date = session.startDate,
            !session.mountainName.isEmpty
        else {
            return nil
        }

        self.id = id
        self.mountainName = session.mountainName
        self.date = date
        self.playerCount = (session.players as? Set<Player>)?.count ?? 0
    }
}

struct MountainPreview: Identifiable, Equatable {
    let id: String
    let name: String
    let isGlobal: Bool
}
