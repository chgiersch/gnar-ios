//
//  ScoreSummary.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//

import Foundation

struct ScoreSummary: Identifiable {
    let id: UUID
    let lineName: String?
    let points: Int
}
