//
//  LineScore.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import Foundation
import CoreData
import SwiftUI

@objc(LineScore)
public class LineScore: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var lineWorth: LineWorth?
    @NSManaged public var snowLevel: String?
    @NSManaged public var score: Score?

    public var points: Int {
        guard let snowLevel = SnowLevel(rawValue: snowLevel ?? ""),
              let lineWorth = lineWorth else { return 0 }

        switch snowLevel {
        case .low:
            return Int(truncating: lineWorth.basePointsLow ?? 0)
        case .medium:
            return Int(truncating: lineWorth.basePointsMedium ?? 0)
        case .high:
            return Int(truncating: lineWorth.basePointsHigh ?? 0)
        }
    }
}

public enum SnowLevel: String, CaseIterable {
    case low, medium, high
    
    var displayColor: Color {
        switch self {
        case .low: return .red
        case .medium: return .purple
        case .high: return .blue
        }
    }
    
    var displayName: String {
        self.rawValue.capitalized
    }
}

public extension LineScore {
    static func create(in context: NSManagedObjectContext, lineWorth: LineWorth, snowLevel: SnowLevel) -> LineScore {
        let entity = NSEntityDescription.entity(forEntityName: "LineScore", in: context)!
        let lineScore = LineScore(entity: entity, insertInto: context)
        lineScore.id = UUID()
        lineScore.lineWorth = lineWorth
        lineScore.snowLevel = snowLevel.rawValue
        return lineScore
    }
}
