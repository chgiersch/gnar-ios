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
    // MARK: - Properties
    
    let gameSession: GameSession
    let viewContext: NSManagedObjectContext
    let selectedPlayer: Player
    
    @Published var selectedTricks: [TrickBonus] = []
    @Published var selectedECPs: [ECP] = []
    @Published var selectedPenalties: [Penalty] = []
    @Published var error: Error?
    
    // MARK: - State
    @Published var selectedLine: LineWorth?
    @Published var selectedSnowLevel: SnowLevel = .medium
    
    // MARK: - Computed Properties
    var hasSelectedLine: Bool { selectedLine != nil }
    
    var currentScoreValue: Int {
        var total = 0
        
        // Add line points
        if let line = selectedLine {
            switch selectedSnowLevel {
            case .low:
                total += Int(truncating: line.basePointsLow ?? 0)
            case .medium:
                total += Int(truncating: line.basePointsMedium ?? 0)
            case .high:
                total += Int(truncating: line.basePointsHigh ?? 0)
            }
        }
        
        // Add trick points
        total += selectedTricks.reduce(0) { $0 + Int($1.points) }
        
        // Add ECP points
        total += selectedECPs.reduce(0) { $0 + Int($1.points) }
        
        // Subtract penalty points
        total -= selectedPenalties.reduce(0) { $0 + Int($1.points) }
        
        return total
    }
    
    var scoreValueLabel: String {
        "TOTAL SCORE"
    }
    
    var canAddScore: Bool {
        selectedLine != nil && currentScoreValue > 0
    }
    
    // MARK: - Initialization
    
    init(viewContext: NSManagedObjectContext,
         selectedPlayer: Player,
         gameSession: GameSession) {
        self.viewContext = viewContext
        self.selectedPlayer = selectedPlayer
        self.gameSession = gameSession
    }
    
    // MARK: - Score Management
    
    func saveCurrentScore() async throws {
        let score = Score(context: viewContext)
        score.id = UUID()
        score.timestamp = Date()
        score.player = selectedPlayer
        score.gameSession = gameSession
        
        // Add line score if selected
        var linePoints: Int32 = 0
        if let line = selectedLine {
            let lineScore = LineScore(context: viewContext)
            lineScore.id = UUID()
            lineScore.lineWorth = line
            lineScore.snowLevel = selectedSnowLevel.rawValue
            switch selectedSnowLevel {
            case .low:
                lineScore.points = line.basePointsLow?.int32Value ?? 0
            case .medium:
                lineScore.points = line.basePointsMedium?.int32Value ?? 0
            case .high:
                lineScore.points = line.basePointsHigh?.int32Value ?? 0
            }
            score.lineScore = lineScore
            linePoints = lineScore.points
        }
        
        // Add trick bonus scores
        var totalTrickPoints: Int32 = 0
        for trick in selectedTricks {
            let trickScore = TrickBonusScore(context: viewContext)
            trickScore.id = UUID()
            trickScore.timestamp = Date()
            trickScore.trickBonus = trick
            trickScore.points = trick.points
            score.addToTrickBonusScores(trickScore)
            totalTrickPoints += trick.points
        }
        
        // Add ECP scores
        var totalECPPoints: Int32 = 0
        for ecp in selectedECPs {
            let ecpScore = ECPScore(context: viewContext)
            ecpScore.id = UUID()
            ecpScore.timestamp = Date()
            ecpScore.ecp = ecp
            ecpScore.points = ecp.points
            score.addToEcpScores(ecpScore)
            totalECPPoints += ecp.points
        }
        
        // Add penalty scores
        var totalPenaltyPoints: Int32 = 0
        for penalty in selectedPenalties {
            let penaltyScore = PenaltyScore(context: viewContext)
            penaltyScore.id = UUID()
            penaltyScore.timestamp = Date()
            penaltyScore.penalty = penalty
            penaltyScore.points = penalty.points
            score.addToPenaltyScores(penaltyScore)
            totalPenaltyPoints += penalty.points
        }
        
        // Calculate and store final scores
        score.proScore = linePoints + totalTrickPoints + totalECPPoints - totalPenaltyPoints
        score.gnarScore = abs(linePoints) + abs(totalTrickPoints) + abs(totalECPPoints) + abs(totalPenaltyPoints)
        
        try viewContext.save()
    }
    
    // MARK: - Actions
    func setSelectedLine(_ line: LineWorth, snowLevel: SnowLevel) {
        selectedLine = line
        selectedSnowLevel = snowLevel
    }
    
    func resetSelection() {
        selectedLine = nil
        selectedSnowLevel = .medium
        selectedTricks = []
        selectedECPs = []
        selectedPenalties = []
    }
}
