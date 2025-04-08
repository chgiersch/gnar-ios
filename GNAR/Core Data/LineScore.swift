//
//  LineScore.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import Foundation
import CoreData

@objc(LineScore)
public class LineScore: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var lineWorth: LineWorth?
    @NSManaged public var snowLevel: String?
    @NSManaged public var score: Score?

    public var points: Int {
        switch SnowLevel(rawValue: snowLevel ?? "") {
        case .low:
            return Int(truncating: lineWorth?.basePointsLow ?? 0)
        case .medium:
            return Int(truncating: lineWorth?.basePointsMedium ?? 0)
        case .high:
            return Int(truncating: lineWorth?.basePointsHigh ?? 0)
        case .none:
            return 0
        }
    }
}

public enum SnowLevel: String, CaseIterable {
    case low, medium, high
}

public extension LineScore {
    static func create(in context: NSManagedObjectContext, lineWorth: LineWorth, snowLevel: String) -> LineScore {
        let entity = NSEntityDescription.entity(forEntityName: "LineScore", in: context)!
        let lineScore = LineScore(entity: entity, insertInto: context)
        lineScore.id = UUID()
        lineScore.lineWorth = lineWorth
        lineScore.snowLevel = snowLevel
        return lineScore
    }
}
