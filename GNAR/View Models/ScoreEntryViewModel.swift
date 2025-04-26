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
    
    let gameState: GameState
    
    @Published var selectedLine: LineWorth?
    @Published var selectedSnowLevel: SnowLevel = .medium
    @Published var selectedTricks: [TrickBonus] = []
    @Published var selectedECPs: [ECP] = []
    @Published var selectedPenalties: [Penalty] = []
    @Published var error: Error?
    @Published var isLoading = false
    @Published var didSaveScore = false
    
    // Data for pickers
    @Published private(set) var availableTricks: [TrickBonus] = []
    @Published private(set) var availableECPs: [ECP] = []
    @Published private(set) var availablePenalties: [Penalty] = []
    
    // MARK: - Computed Properties
    
    var currentSession: GameSession? { gameState.currentSession }
    var players: [Player] { gameState.players }
    var scores: [Score] { gameState.scores }
    var viewContext: NSManagedObjectContext { gameState.viewContext }
    
    var currentScoreValue: Int {
        var total = 0
        
        // Add line points if selected
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
    
    var canAddScore: Bool {
        selectedLine != nil || !selectedTricks.isEmpty || !selectedECPs.isEmpty || !selectedPenalties.isEmpty
    }
    
    // MARK: - Initialization
    
    init(gameState: GameState) {
        self.gameState = gameState
    }
    
    // MARK: - Data Loading
    
    func loadAvailableItems() async {
        // Guard against loading multiple times
        guard availableTricks.isEmpty || availableECPs.isEmpty || availablePenalties.isEmpty else {
            print("ScoreEntryViewModel: Items already loaded, skipping load")
            return
        }
        
        guard let currentMountain = currentSession?.mountain else { 
            print("ScoreEntryViewModel: Cannot load items - no mountain set")
            return 
        }
        
        print("ScoreEntryViewModel: Loading available items")
        isLoading = true
        defer { 
            isLoading = false 
            print("ScoreEntryViewModel: Finished loading available items")
        }
        
        await loadTricks()
        await loadECPs()
        await loadPenalties()
    }
    
    private func loadTricks() async {
        guard let currentMountain = currentSession?.mountain else { 
            print("ScoreEntryViewModel: Cannot load tricks - no mountain set")
            return 
        }
        
        do {
            let request = TrickBonus.fetchRequest()
            
            // First, let's debug what we can find without filters
            let allTricks = try await viewContext.fetch(request)
            print("ScoreEntryViewModel: Found \(allTricks.count) total tricks in database")
            
            // Try to find the Global mountain by name since isGlobal flag might not be set
            let globalRequest = Mountain.fetchRequest()
            globalRequest.predicate = NSPredicate(format: "name == %@", "Global")
            let globalMountains = try await viewContext.fetch(globalRequest)
            print("ScoreEntryViewModel: Found \(globalMountains.count) global mountains by name")
            
            if !globalMountains.isEmpty {
                let globalMountain = globalMountains.first!
                
                if currentMountain.name == "Global" {
                    // If we're on Global mountain, just use that
                    request.predicate = NSPredicate(format: "mountain == %@", currentMountain)
                } else {
                    // Otherwise, include both current mountain and Global mountain
                    request.predicate = NSPredicate(format: "mountain == %@ OR mountain == %@", currentMountain, globalMountain)
                }
            } else {
                // Fallback: no filters, just grab all tricks
                // This is a fallback in case mountains aren't properly linked
                print("ScoreEntryViewModel: No Global mountain found, loading all tricks")
            }
            
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TrickBonus.name, ascending: true)]
            self.availableTricks = try await viewContext.fetch(request)
            print("ScoreEntryViewModel: Loaded \(self.availableTricks.count) tricks")
        } catch {
            print("ScoreEntryViewModel: Failed to load tricks: \(error.localizedDescription)")
            self.error = error
        }
    }
    
    private func loadECPs() async {
        guard let currentMountain = currentSession?.mountain else { 
            print("ScoreEntryViewModel: Cannot load ECPs - no mountain set")
            return 
        }
        
        do {
            let request = ECP.fetchRequest()
            
            // Get the global mountain by name
            let globalRequest = Mountain.fetchRequest()
            globalRequest.predicate = NSPredicate(format: "name == %@", "Global")
            let globalMountains = try await viewContext.fetch(globalRequest)
            
            if !globalMountains.isEmpty {
                let globalMountain = globalMountains.first!
                
                if currentMountain.name == "Global" {
                    // If we're on Global mountain, just use that
                    request.predicate = NSPredicate(format: "mountain == %@", currentMountain)
                } else {
                    // Otherwise, include both current mountain and Global mountain
                    request.predicate = NSPredicate(format: "mountain == %@ OR mountain == %@", currentMountain, globalMountain)
                }
            } else {
                // Fallback to just the current mountain
                request.predicate = NSPredicate(format: "mountain == %@", currentMountain)
            }
            
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ECP.name, ascending: true)]
            self.availableECPs = try await viewContext.fetch(request)
            print("ScoreEntryViewModel: Loaded \(self.availableECPs.count) ECPs")
        } catch {
            print("ScoreEntryViewModel: Failed to load ECPs: \(error.localizedDescription)")
            self.error = error
        }
    }
    
    private func loadPenalties() async {
        guard let currentMountain = currentSession?.mountain else { 
            print("ScoreEntryViewModel: Cannot load penalties - no mountain set")
            return 
        }
        
        do {
            let request = Penalty.fetchRequest()
            
            // First, let's debug what we can find without filters
            let allPenalties = try await viewContext.fetch(request)
            print("ScoreEntryViewModel: Found \(allPenalties.count) total penalties in database")
            
            // Get the global mountain by name
            let globalRequest = Mountain.fetchRequest()
            globalRequest.predicate = NSPredicate(format: "name == %@", "Global")
            let globalMountains = try await viewContext.fetch(globalRequest)
            print("ScoreEntryViewModel: Found \(globalMountains.count) global mountains by name")
            
            if !globalMountains.isEmpty {
                let globalMountain = globalMountains.first!
                
                if currentMountain.name == "Global" {
                    // If we're on Global mountain, just use that
                    request.predicate = NSPredicate(format: "mountain == %@", currentMountain)
                } else {
                    // Otherwise, include both current mountain and Global mountain
                    request.predicate = NSPredicate(format: "mountain == %@ OR mountain == %@", currentMountain, globalMountain)
                }
            } else {
                // Fallback: no filters, just grab all penalties
                // This is a fallback in case mountains aren't properly linked
                print("ScoreEntryViewModel: No Global mountain found, loading all penalties")
            }
            
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Penalty.name, ascending: true)]
            self.availablePenalties = try await viewContext.fetch(request)
            print("ScoreEntryViewModel: Loaded \(self.availablePenalties.count) penalties")
        } catch {
            print("ScoreEntryViewModel: Failed to load penalties: \(error.localizedDescription)")
            self.error = error
        }
    }
    
    // MARK: - Actions
    
    func saveScore() async throws {
        guard let player = gameState.selectedPlayer else {
            throw ScoreError.missingRequiredFields
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Create and populate the Score object
            let score = Score(context: gameState.viewContext)
            score.id = UUID()
            score.player = player
            score.timestamp = Date()
            score.gameSession = currentSession
            
            // Add line score if selected
            if let line = selectedLine {
                let lineScore = LineScore(context: gameState.viewContext)
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
            }
            
            // Add trick bonus scores
            for trick in selectedTricks {
                let trickScore = TrickBonusScore(context: gameState.viewContext)
                trickScore.id = UUID()
                trickScore.timestamp = Date()
                trickScore.trickBonus = trick
                trickScore.points = trick.points
                score.addToTrickBonusScores(trickScore)
            }
            
            // Add ECP scores
            for ecp in selectedECPs {
                let ecpScore = ECPScore(context: gameState.viewContext)
                ecpScore.id = UUID()
                ecpScore.timestamp = Date()
                ecpScore.ecp = ecp
                ecpScore.points = ecp.points
                score.addToEcpScores(ecpScore)
            }
            
            // Add penalty scores
            for penalty in selectedPenalties {
                let penaltyScore = PenaltyScore(context: gameState.viewContext)
                penaltyScore.id = UUID()
                penaltyScore.timestamp = Date()
                penaltyScore.penalty = penalty
                penaltyScore.points = penalty.points
                score.addToPenaltyScores(penaltyScore)
            }
            
            // Calculate the final score
            score.calculateTotalScore()
            
            // Save to CoreData and update the app state
            try await gameState.addScore(score)
            
            // Reset form
            resetSelection()
            
            // Set the flag to signal the save was successful
            // This will trigger UI updates through the onChange in the parent
            didSaveScore = true
        } catch {
            self.error = error
            throw error
        }
    }
    
    func deleteScore(_ score: Score) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await gameState.deleteScore(score)
        } catch {
            self.error = error
        }
    }
    
    func resetSelection() {
        selectedLine = nil
        selectedSnowLevel = .medium
        selectedTricks = []
        selectedECPs = []
        selectedPenalties = []
    }
}

// MARK: - Error Types

enum ScoreError: Error {
    case missingRequiredFields
}
