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
    var editingScore: Score? = nil

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
    
    func saveScore(for selectedPlayer: Player) -> Score {
        if let score = editingScore {
            print("✏️ Editing existing Score")

            // Update player and session references if needed
            score.playerID = selectedPlayer.id
            score.timestamp = Date()
            score.gameSession = session

            // Clear existing associations
            score.lineScore = nil
            score.setValue(NSSet(), forKey: "trickBonusScores")
            score.setValue(NSSet(), forKey: "ecpScores")
            score.setValue(NSSet(), forKey: "penaltyScores")

            // Re-apply LineScore if selected
            if let selectedLine = selectedLineScore {
                score.lineScore = selectedLine
            }

            // Re-add Tricks
            for trick in selectedTricks {
                score.addTrickBonusScore(trick, context: context)
            }

            // Re-add ECPs
            for ecp in selectedECPs {
                score.addECPScore(ecp, context: context)
            }

            // Re-add Penalties
            for penalty in selectedPenalties {
                score.addPenaltyScore(penalty, context: context)
            }

            try? context.save()
            return score

        } else {
            return addScore(for: selectedPlayer) 
        }
    }
    
    func load(from score: Score) {
        print("📦 Loading Score into ViewModel:", score.id?.uuidString ?? "nil")
        self.editingScore = score
        self.selectedLineScore = score.lineScore

        if let trickScores = score.trickBonusScores?.allObjects as? [TrickBonusScore] {
            self.selectedTricks = trickScores.compactMap { $0.trickBonus }
            print("🎿 Loaded Tricks:", self.selectedTricks.map { $0.name })
        }

        if let ecpScores = score.ecpScores?.allObjects as? [ECPScore] {
            self.selectedECPs = ecpScores.compactMap { $0.ecp }
            print("🌟 Loaded ECPs:", self.selectedECPs.map { $0.name })
        }

        if let penaltyScores = score.penaltyScores?.allObjects as? [PenaltyScore] {
            self.selectedPenalties = penaltyScores.compactMap { $0.penalty }
            print("⚠️ Loaded Penalties:", self.selectedPenalties.map { $0.name })
        }
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
