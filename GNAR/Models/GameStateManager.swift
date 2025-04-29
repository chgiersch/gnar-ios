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
        print("🎮 GameStateManager: Starting to add score \(score.id)")
        isLoading = true
        defer { isLoading = false }
        
        guard let session = currentSession else {
            print("❌ GameStateManager: No active session found")
            throw NSError(domain: "GameSession", 
                         code: 404, 
                         userInfo: [NSLocalizedDescriptionKey: "No active session for score"])
        }
        
        print("🔗 GameStateManager: Associating score with session \(session.id)")
        // Make sure the score is associated with the session
        score.gameSession = session
        
        print("📊 GameStateManager: Calculating total score")
        // Ensure the score has correct total values
        score.calculateTotalScore()
        
        print("💾 GameStateManager: Saving to Core Data")
        // Save the context
        try viewContext.save()
        print("✅ GameStateManager: Score saved successfully")
    }
    
    /// Deletes a score from the database
    func deleteScore(_ score: Score) async throws {
        print("🗑️ GameStateManager: Starting to soft delete score \(score.id)")
        isLoading = true
        defer { isLoading = false }
        
        print("⚠️ GameStateManager: Soft deleting score")
        score.softDelete()
        
        print("💾 GameStateManager: Saving context after soft delete")
        try viewContext.save()
        
        // Instead of reloading the entire leaderboard, just update the session's scores
        if let session = currentSession {
            print("🔄 GameStateManager: Updating session scores")
            let activeScores = session.scoresArray.filter { !$0.isSoftDeleted }
            session.scores = NSSet(array: activeScores)
            try viewContext.save()
        }
        
        print("✅ GameStateManager: Score soft deleted successfully")
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
        print("📊 GameStateManager: Starting leaderboard load")
        guard let session = currentSession else {
            print("❌ GameStateManager: No active session for leaderboard")
            throw NSError(domain: "GameSession", 
                         code: 404, 
                         userInfo: [NSLocalizedDescriptionKey: "No active session for leaderboard"])
        }
        
        print("🔍 GameStateManager: Creating fetch request for session \(session.id)")
        let request: NSFetchRequest<Score> = Score.fetchRequest()
        request.predicate = NSPredicate(format: "gameSession == %@", session)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Score.createdAt, ascending: false)
        ]
        
        print("📥 GameStateManager: Fetching scores from Core Data")
        print("  ℹ️ Current session has \(session.scoresArray.count) scores")
        print("  ℹ️ Fetching with predicate: gameSession == \(session.id)")
        
        do {
            let scores = try await viewContext.fetch(request)
            print("✅ GameStateManager: Fetched \(scores.count) scores")
            print("  ℹ️ First score ID: \(scores.first?.id.uuidString ?? "none")")
            print("  ℹ️ First score createdAt: \(scores.first?.createdAt.description ?? "nil")")
            
            print("🧮 GameStateManager: Calculating total scores")
            scores.forEach { score in
                print("  📝 Calculating score \(score.id)")
                print("    ℹ️ Score has lineScore: \(score.lineScore != nil)")
                print("    ℹ️ Score has trickBonusScores: \(score.trickBonusScores?.count ?? 0)")
                print("    ℹ️ Score has ecpScores: \(score.ecpScores?.count ?? 0)")
                print("    ℹ️ Score has penaltyScores: \(score.penaltyScores?.count ?? 0)")
                score.calculateTotalScore()
            }
            
            print("🔄 GameStateManager: Updating session scores")
            // Update the session's scores without replacing the entire session object
            session.scores = NSSet(array: scores)
            
            print("💾 GameStateManager: Saving context after leaderboard update")
            try viewContext.save()
            print("✅ GameStateManager: Leaderboard load complete")
        } catch {
            print("❌ GameStateManager: Error during leaderboard load: \(error)")
            print("  ℹ️ Error description: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Updates the leaderboard by saving changes to the context
    func updateLeaderboard() async throws {
        guard let session = currentSession else { return }
        try viewContext.save()
    }
} 
