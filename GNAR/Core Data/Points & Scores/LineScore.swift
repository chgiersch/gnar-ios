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
    @NSManaged public var snowLevelRaw: Int16
    @NSManaged public var points: Int32
    @NSManaged public var score: Score?
    
    var snowLevel: SnowLevel {
        get {
            SnowLevel(rawValue: snowLevelRaw) ?? .medium
        }
        set {
            self.snowLevelRaw = newValue.rawValue
        }
    }
    
    convenience init(context: NSManagedObjectContext, lineWorth: LineWorth, snowLevel: SnowLevel) {
        self.init(context: context)
        self.id = UUID()
        self.lineWorth = lineWorth
        self.snowLevel = snowLevel
        
        switch snowLevel {
        case .low:
            self.points = lineWorth.basePointsLow?.int32Value ?? 0
        case .medium:
            self.points = lineWorth.basePointsMedium?.int32Value ?? 0
        case .high:
            self.points = lineWorth.basePointsHigh?.int32Value ?? 0
        }
    }
}

@objc public enum SnowLevel: Int16, CaseIterable, Hashable, Codable {
    case low = 0
    case medium = 1
    case high = 2
    
    var displayColor: Color {
        switch self {
        case .low: return .red
        case .medium: return .purple
        case .high: return .blue
        }
    }
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

extension LineScore {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LineScore> {
        return NSFetchRequest<LineScore>(entityName: "LineScore")
    }
}
