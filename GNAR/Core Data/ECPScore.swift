//
//  ECPScore.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//


import Foundation
import CoreData

@objc(ECPScore)
public class ECPScore: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date?
    @NSManaged public var points: Int32
    @NSManaged public var verified: Bool
    
    @NSManaged public var ecp: ECP?
    @NSManaged public var score: Score?
}

extension ECPScore {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ECPScore> {
        return NSFetchRequest<ECPScore>(entityName: "ECPScore")
    }
    
    static func create(in context: NSManagedObjectContext, ecp: ECP, into score: Score) -> ECPScore {
        let ecpScore = ECPScore(context: context)
        ecpScore.id = UUID()
        ecpScore.ecp = ecp
        ecpScore.timestamp = Date()
        ecpScore.points = ecp.points
        ecpScore.verified = false
        ecpScore.score = score
        return ecpScore
    }
}
