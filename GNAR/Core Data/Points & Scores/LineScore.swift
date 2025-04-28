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
    @NSManaged public var points: Int32
    @NSManaged public var score: Score?
}

public enum SnowLevel: String, CaseIterable, Hashable {
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

extension LineScore {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LineScore> {
        return NSFetchRequest<LineScore>(entityName: "LineScore")
    }
    
    static func create(in context: NSManagedObjectContext, lineWorth: LineWorth, snowLevel: SnowLevel) -> LineScore {
        let lineScore = LineScore(context: context)
        lineScore.id = UUID()
        lineScore.lineWorth = lineWorth
        lineScore.snowLevel = snowLevel.rawValue
        
        // Calculate and store points based on snow level
        switch snowLevel {
        case .low:
            lineScore.points = lineWorth.basePointsLow?.int32Value ?? 0
        case .medium:
            lineScore.points = lineWorth.basePointsMedium?.int32Value ?? 0
        case .high:
            lineScore.points = lineWorth.basePointsHigh?.int32Value ?? 0
        }
        
        return lineScore
    }
}
