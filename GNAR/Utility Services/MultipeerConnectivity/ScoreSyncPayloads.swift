//
//  ScoreSyncPayloads.swift
//  GNAR
//
//  Created by Chris Giersch on 4/27/25.
//

import Foundation

struct ScoreSyncPayload: Codable {
    let id: UUID
    let playerId: UUID
    let gameSessionId: UUID
    let creatorName: String
    let createdAt: Date
    let modifiedAt: Date
    let isSoftDeleted: Bool
    let gnarScore: Int32
    let heroScore: Int32
    let lineScore: LineScorePayload?
    let trickBonusScores: [TrickBonusScorePayload]
    let ecpScores: [ECPSyncPayload]
    let penaltyScores: [PenaltySyncPayload]
}

struct LineScorePayload: Codable {
    let id: UUID
    let lineWorthId: UUID
    let snowLevel: SnowLevel
    let points: Int32
}

struct TrickBonusScorePayload: Codable {
    let id: UUID
    let trickBonusId: UUID
    let points: Int32
    let timestamp: Date
}

struct ECPSyncPayload: Codable {
    let id: UUID
    let ecpId: UUID
    let points: Int32
    let timestamp: Date
}

struct PenaltySyncPayload: Codable {
    let id: UUID
    let penaltyId: UUID
    let points: Int32
    let timestamp: Date
}

extension LineScore {
    func toPayload() -> LineScorePayload? {
        guard let lineWorthId = lineWorth?.id else {
            print("⚠️ Missing LineWorth for LineScore \(id)")
            return nil
        }
        
        return LineScorePayload(
            id: id,
            lineWorthId: lineWorthId,
            snowLevel: snowLevel,
            points: points
        )
    }
}

extension TrickBonusScore {
    func toPayload() -> TrickBonusScorePayload {
        return TrickBonusScorePayload(
            id: id,
            trickBonusId: trickBonus?.id ?? UUID(),
            points: points,
            timestamp: timestamp ?? Date()  // Safety fallback
        )
    }
}

extension ECPScore {
    func toPayload() -> ECPSyncPayload {
        return ECPSyncPayload(
            id: id,
            ecpId: ecp?.id ?? UUID(),
            points: points,
            timestamp: timestamp ?? Date()
        )
    }
}

extension PenaltyScore {
    func toPayload() -> PenaltySyncPayload {
        return PenaltySyncPayload(
            id: id,
            penaltyId: penalty?.id ?? UUID(),
            points: points,
            timestamp: timestamp ?? Date()
        )
    }
}
