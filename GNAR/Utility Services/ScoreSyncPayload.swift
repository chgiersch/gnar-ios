//
//  ScoreSyncPayload.swift
//  GNAR
//
//  Created by Chris Giersch on 4/27/25.
//

import Foundation

struct ScoreSyncPayload: Codable {
    let id: UUID
    let playerId: UUID
    let createdAt: Date
    let modifiedAt: Date
    let isSoftDeleted: Bool
    let gnarScore: Int32
    let heroScore: Int32
    let lineScoreId: UUID?
    let trickBonusScoreIds: [UUID]
    let ecpScoreIds: [UUID]
    let penaltyScoreIds: [UUID]
}
