import Foundation
import CoreData
import SwiftUI

@MainActor
final class GameStateManager: ObservableObject, GameState {
  
    // MARK: - Properties
    
    let viewContext: NSManagedObjectContext
    private let appState: AppState
    
    @Published private(set) var currentSession: GameSession?
    @Published var selectedPlayer: Player? {
        didSet {
            if selectedPlayer?.id != oldValue?.id {
                print("GameStateManager: selectedPlayer changed from \(oldValue?.name ?? "nil") to \(selectedPlayer?.name ?? "nil")")
                objectWillChange.send()
            }
        }
    }
    @Published var error: Error?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingSessions: Bool = false
    
    var sessions: [GameSession] { 
        appState.sessions
    }
    
    var visibleSessions: [GameSession] { 
        appState.visibleSessions
    }
    
    // MARK: - Initialization
    
    init(viewContext: NSManagedObjectContext, appState: AppState) {
        self.viewContext = viewContext
        self.appState = appState
    }
    
    // MARK: - Sessions Management
    
    func loadSessions() async throws {
        // Delegate to AppState
        try await appState.loadSessions()
    }
    
    // MARK: - Session Management
    
    /// Loads a specific game session and sets it as the current session
    func loadSession(_ session: GameSession) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            currentSession = session
            selectedPlayer = session.playersArray.first
            try await loadLeaderboard()
            
            // Make sure session is in app state
            appState.addSession(session)
        } catch {
            // Reset state on error
            currentSession = nil
            selectedPlayer = nil
            throw error
        }
    }

    /// Loads a session by its UUID
    func loadSessionById(_ id: UUID) async throws {
        let request = GameSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        guard let session = try await viewContext.fetch(request).first else {
            throw NSError(domain: "GameSession", code: 404, userInfo: [NSLocalizedDescriptionKey: "Session not found"])
        }
        
        try await loadSession(session)
    }
    
    /// Creates a new game session with the specified mountain and players
    func startNewSession(mountain: Mountain, players: [Player]) async throws -> GameSession {
        isLoading = true
        defer { isLoading = false }
        
        let session = GameSession(context: viewContext)
        session.id = UUID()
        session.startDate = Date()
        session.mountain = mountain
        session.players = NSSet(array: players)
        
        try viewContext.save()
        currentSession = session
        selectedPlayer = players.first
        
        // Add to app state
        appState.addSession(session)
        
        return session
    }
        
    /// Deletes the current game session
    func deleteSession() async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let session = currentSession else {
            throw NSError(domain: "GameSession", 
                         code: 404, 
                         userInfo: [NSLocalizedDescriptionKey: "No active session to delete"])
        }
        
        // Remove from app state
        appState.removeSession(session)
        
        viewContext.delete(session)
        try viewContext.save()
        
        currentSession = nil
        selectedPlayer = nil
    }
    
    // MARK: - Score Management
    
    /// Adds a score to the current session
    func addScore(_ score: Score) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let session = currentSession else {
            throw NSError(domain: "GameSession", 
                         code: 404, 
                         userInfo: [NSLocalizedDescriptionKey: "No active session for score"])
        }
        
        // Make sure the score is associated with the session
        score.gameSession = session
        
        // Ensure the score has correct total values
        score.calculateTotalScore()
        
        // Save the context
        try viewContext.save()
    }
    
    /// Deletes a score from the database
    func deleteScore(_ score: Score) async throws {
        isLoading = true
        defer { isLoading = false }
        
        viewContext.delete(score)
        try viewContext.save()
        try await loadLeaderboard()
    }
    
    // MARK: - Player Management

    var players: [Player] { currentSession?.playersArray ?? [] }
    var scores: [Score] { currentSession?.scoresArray ?? [] }
    var mountain: Mountain? { currentSession?.mountain }
    
    // MARK: - Leaderboard
    
    /// Returns leaderboard summaries for all players in the current session
    var leaderboardSummaries: [LeaderboardSummary] {
        guard let session = currentSession else { return [] }
        
        // Create summaries for all players
        var summaries = players.map { player in
            LeaderboardSummary(player: player, gameSession: session)
        }
        
        // Sort by score (descending) then by name (ascending)
        summaries.sort { (a, b) in
            if a.gnarScore != b.gnarScore {
                return a.gnarScore > b.gnarScore // Higher score first
            } else {
                return a.playerName.localizedCaseInsensitiveCompare(b.playerName) == .orderedAscending
            }
        }
        
        // Assign ranks after sorting
        for (index, _) in summaries.enumerated() {
            summaries[index].rank = index + 1
        }
        
        return summaries
    }

    /// Returns scores filtered for the currently selected player
    var filteredScores: [Score] {
        guard let selected = selectedPlayer else { return [] }
        return scores.filter { $0.player?.id == selected.id }
    }
    
    /// Loads the leaderboard for the current session
    func loadLeaderboard() async throws {
        guard let session = currentSession else {
            throw NSError(domain: "GameSession", 
                         code: 404, 
                         userInfo: [NSLocalizedDescriptionKey: "No active session for leaderboard"])
        }
        
        let request: NSFetchRequest<Score> = Score.fetchRequest()
        request.predicate = NSPredicate(format: "gameSession == %@", session)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Score.timestamp, ascending: false)
        ]
        
        let scores = try await viewContext.fetch(request)
        
        // Ensure all scores have correct gnarScore and heroScore values
        scores.forEach { score in
            score.calculateTotalScore()
        }
        
        // Update the session's scores without replacing the entire session object
        session.scores = NSSet(array: scores)
        try viewContext.save()
    }
    
    /// Updates the leaderboard by saving changes to the context
    func updateLeaderboard() async throws {
        guard let session = currentSession else { return }
        try viewContext.save()
    }
} 
