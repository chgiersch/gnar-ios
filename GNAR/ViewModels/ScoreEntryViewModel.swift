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
    @Published var playerName: String
    
    @Published var selectedLineScore: LineScore?
    @Published var selectedTricks: [TrickBonus] = []
    @Published var selectedECPs: [String] = []
    @Published var selectedPenalties: [String] = []
    
    @Published var showingLineWorthPicker = false
    @Published var showingTrickPicker = false
    @Published var showingECPPicker = false
    @Published var showingPenaltyPicker = false
    
    var totalPoints: Int {
        let linePoints = selectedLineScore?.points ?? 0
        return linePoints
    }
    
    let context: NSManagedObjectContext
    
    init(playerName: String, context: NSManagedObjectContext) {
        self.playerName = playerName
        self.context = context
    }
    
    func showLinePicker() { showingLineWorthPicker = true }
    func showTrickPicker() { showingTrickPicker = true }
    func showECPPicker() { showingECPPicker = true }
    func showPenaltyPicker() { showingPenaltyPicker = true }
    
    func removeLine() { selectedLineScore = nil }
    
    func addScore() -> Score {
        let score = Score(context: context)
        score.id = UUID()
        score.playerID = UUID() // Replace with actual player ID later
        score.lineScore = selectedLineScore
        score.timestamp = Date()
        
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Failed to save score: \(error)")
        }
        
        return score
    }

    func fetchTrickBonuses() -> [TrickBonus] {
        let request: NSFetchRequest<TrickBonus> = TrickBonus.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch Trick Bonuses: \(error)")
            return []
        }
    }

    func fetchECPs() -> [ECP] {
        let request: NSFetchRequest<ECP> = ECP.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch ECPs: \(error)")
            return []
        }
    }

    func fetchPenalties() -> [Penalty] {
        let request: NSFetchRequest<Penalty> = Penalty.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch Penalties: \(error)")
            return []
        }
    }
}

