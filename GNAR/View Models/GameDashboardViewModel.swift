//
//  GameDashboardViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class GameDashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var scoreEntryViewModel: ScoreEntryViewModel?
    @Published private(set) var isSessionLoaded = false
    
    @Published var gameState: GameState?
    
    var session: GameSession {
        guard let gameState = gameState, let session = gameState.currentSession else {
            fatalError("GameDashboardViewModel accessed without a valid session. This should never happen as the view should only be presented with a valid session.")
        }
        return session
    }

    var selectedPlayer: Player? {
        get { gameState?.selectedPlayer }
        set { 
            if gameState?.selectedPlayer?.id != newValue?.id {
                print("GameDashboardViewModel: Setting selectedPlayer to \(newValue?.name ?? "nil")")
                gameState?.selectedPlayer = newValue
                objectWillChange.send()
            }
        }
    }

    var error: Error? {
        get { gameState?.error }
        set { 
            if let newValue = newValue {
                gameState?.error = newValue
            }
        }
    }    
        
    var players: [Player] { gameState?.players ?? [] }
    var scores: [Score] { gameState?.scores ?? [] }
    var leaderboardSummaries: [LeaderboardSummary] { gameState?.leaderboardSummaries ?? [] }
    var filteredScores: [Score] { gameState?.filteredScores ?? [] }
    
    // MARK: - Initialization
    
    init(gameState: GameState?) {
        self.gameState = gameState
        print("GameDashboardViewModel initialized")
    }
    
    /// Creates a ScoreEntryViewModel if one doesn't already exist
    func updateScoreEntryViewModel() {
        if let gameState = gameState, scoreEntryViewModel == nil {
            print("GameDashboardViewModel: Creating new ScoreEntryViewModel")
            self.scoreEntryViewModel = ScoreEntryViewModel(gameState: gameState)
        }
    }
    
    // MARK: - Session Management

    /// Load a specific session, or the current one if none provided
    func loadSession(_ session: GameSession? = nil) async {
        guard let gameState = gameState else {
            print("GameDashboardViewModel: No gameState available")
            return
        }
        
        // If already loaded and no new session provided, don't reload
        if isSessionLoaded && session == nil {
            print("GameDashboardViewModel: Session already loaded, skipping")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let specificSession = session {
                // Load the provided session
                print("GameDashboardViewModel: Loading session: \(specificSession.id.uuidString)")
                try await gameState.loadSession(specificSession)
            } else if let currentSession = gameState.currentSession {
                // Load the current session by ID
                print("GameDashboardViewModel: Reloading current session")
                try await gameState.loadSessionById(currentSession.id)
            } else {
                print("GameDashboardViewModel: No session to load")
                return
            }
            
            isSessionLoaded = true
            
            // Create ScoreEntryViewModel only once
            if scoreEntryViewModel == nil {
                updateScoreEntryViewModel()
                
                // Load the available items if needed
                if let mountain = gameState.currentSession?.mountain, let viewModel = scoreEntryViewModel {
                    await viewModel.loadAvailableItems()
                }
            }
        } catch {
            print("GameDashboardViewModel: Error loading session: \(error.localizedDescription)")
            self.error = error
        }
    }
    
    func deleteScore(_ score: Score) async {
        guard let gameState = gameState else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await gameState.deleteScore(score)
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Player Management
    
    func selectPlayer(_ player: Player) {
        print("GameDashboardViewModel: Selecting player \(player.name)")
        gameState?.selectedPlayer = player
        print("GameDashboardViewModel: After selection, selectedPlayer = \(gameState?.selectedPlayer?.name ?? "nil")")
    }
    
    func clearSelectedPlayer() {
        print("GameDashboardViewModel: Clearing selected player")
        gameState?.selectedPlayer = nil
        print("GameDashboardViewModel: After clearing, selectedPlayer = \(gameState?.selectedPlayer?.name ?? "nil")")
    }
    
    // MARK: - Leaderboard
    
    func loadLeaderboard() async {
        guard let gameState = gameState else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await gameState.loadLeaderboard()
        } catch {
            self.error = error
        }
    }

    // MARK: - Scores

    func loadScores() async {
        guard let gameState = gameState else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Just reload the leaderboard which refreshes scores
            try await gameState.loadLeaderboard()
        } catch {
            self.error = error
        }
    }

    /// Prepare the score entry view model for displaying the score entry UI
    func prepareScoreEntry() async -> Bool {
        // Make sure we have a gameState
        guard let gameState = gameState else {
            print("GameDashboardViewModel: No gameState available")
            return false
        }
        
        // Make sure session is loaded
        if !isSessionLoaded {
            await loadSession()
        }
        
        // Create ScoreEntryViewModel if needed
        if scoreEntryViewModel == nil {
            print("GameDashboardViewModel: Creating new ScoreEntryViewModel")
            scoreEntryViewModel = ScoreEntryViewModel(gameState: gameState)
        }
        
        // Load available items
        if let viewModel = scoreEntryViewModel {
            await viewModel.loadAvailableItems()
            return true
        }
        
        return false
    }
}
