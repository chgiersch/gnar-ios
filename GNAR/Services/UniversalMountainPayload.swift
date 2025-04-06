//
//  UniversalMountainPayload.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import Foundation

struct UniversalMountainPayload: Decodable {
    let id: String
    let version: String?
    let name: String
    let trickBonuses: [TrickBonusPayload]?
    let penalties: [PenaltyPayload]?
    let ecps: [ECPPayload]?
    let lineWorths: [LineWorthPayload]?
}

// Basic payloads that match your JSON structure
struct TrickBonusPayload: Decodable {
    let id: String
    let name: String
    let points: Int
}

struct PenaltyPayload: Decodable {
    let id: String
    let name: String
    let descriptionText: String
    let points: Int
    let abbreviation: String
}

struct ECPPayload: Decodable {
    let id: String
    let name: String
    let descriptionText: String
    let points: Int
    let frequency: String
    let abbreviation: String
}

struct LineWorthPayload: Decodable {
    let name: String
    let area: String
    let basePoints: BasePointsFormat
}

enum BasePointsFormat: Decodable {
    case single(Int)
    case tiered(low: Int?, medium: Int?, high: Int?)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let singleValue = try? container.decode(Int.self) {
            self = .single(singleValue)
            return
        }

        if let dict = try? container.decode([String: Int?].self) {
            self = .tiered(
                low: dict["low"] ?? nil,
                medium: dict["medium"] ?? nil,
                high: dict["high"] ?? nil
            )
            return
        }

        throw DecodingError.dataCorruptedError(in: container, debugDescription: "basePoints must be int or {low, medium, high}")
    }
}
