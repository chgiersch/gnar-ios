//
//  ScoreEntryViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//


import Foundation
import SwiftUI
import CoreData

@MainActor
class ScoreEntryViewModel: ObservableObject {
    @Published var selectedLineScore: LineScore?
    @Published var selectedTricks: [TrickBonus] = []
    @Published var selectedECPs: [ECP] = []
    @Published var selectedPenalties: [Penalty] = []

    let context: NSManagedObjectContext
    let session: GameSession

    var totalPoints: Int {
        let linePoints = selectedLineScore?.points ?? 0
        let trickPoints = selectedTricks.reduce(0) { $0 + $1.points }
        let ecpPoints = selectedECPs.reduce(0) { $0 + $1.points }
        let penaltyPoints = selectedPenalties.reduce(0) { $0 + $1.points }
        return Int(Int32(linePoints) + trickPoints + ecpPoints - penaltyPoints)
    }
    
    init(session: GameSession, context: NSManagedObjectContext) {
        self.session = session
        self.context = context
    }
            
    func removeLine() { selectedLineScore = nil }
    func removeTrick(at index: Int) { selectedTricks.remove(at: index) }
    func removeECP(at index: Int) { selectedECPs.remove(at: index) }
    func removePenalty(at index: Int) { selectedPenalties.remove(at: index) }

    /// Creates and saves a Core Data Score based on current selections
    func addScore(for selectedPlayer: Player) -> Score {
        print("🔄 Creating new Score entity...")
        let score = Score(context: context)
        score.id = UUID()
        score.playerID = selectedPlayer.id
        score.lineScore = selectedLineScore
        score.timestamp = Date()
        
        /// Link to the current game session on both sides
        score.gameSession = session
        session.addToScores(score)

        /// Add trick bonuses
        for trick in selectedTricks {
            print("➕ Adding TrickBonus: \(trick.name)")
            score.addTrickBonusScore(trick, context: context)
        }

        /// Add ECPs
        for ecp in selectedECPs {
            print("➕ Adding ECP: \(ecp.name)")
            score.addECPScore(ecp, context: context)
        }

        /// Add penalties
        for penalty in selectedPenalties {
            print("➕ Adding Penalty: \(penalty.name)")
            score.addPenaltyScore(penalty, context: context)
        }

        do {
            try context.save()
            print("💾 Score saved successfully")
        } catch {
            context.rollback()
            print("❌ Failed to save score: \(error)")
        }

        return score
    }
    // MARK: - Fetching Core Data Entities

    func fetchTrickBonuses() -> [TrickBonus] {
        let request: NSFetchRequest<TrickBonus> = TrickBonus.fetchRequest()
        do {
            let trickBonuses = try context.fetch(request)
            print("✅ Fetched \(trickBonuses.count) Trick Bonuses")
            return trickBonuses
        } catch {
            print("❌ Failed to fetch Trick Bonuses: \(error)")
            return []
        }
    }

    func fetchECPs() -> [ECP] {
        let request: NSFetchRequest<ECP> = ECP.fetchRequest()
        do {
            let ecps = try context.fetch(request)
            print("✅ Fetched \(ecps.count) ECPs")
            return ecps
        } catch {
            print("❌ Failed to fetch ECPs: \(error)")
            return []
        }
    }

    func fetchPenalties() -> [Penalty] {
        let request: NSFetchRequest<Penalty> = Penalty.fetchRequest()
        do {
            let penalties = try context.fetch(request)
            print("✅ Fetched \(penalties.count) Penalties")
            return penalties
        } catch {
            print("❌ Failed to fetch Penalties: \(error)")
            return []
        }
    }
}
