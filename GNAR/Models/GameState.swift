import Foundation
import CoreData

/// Protocol defining the core game state management functionality
@MainActor
protocol GameState: AnyObject {
    // MARK: - Core Properties
    var viewContext: NSManagedObjectContext { get }
    var currentSession: GameSession? { get }
    
    // MARK: - User Interface State
    var selectedPlayer: Player? { get set }
    var error: Error? { get set }
    var isLoading: Bool { get }
    var isLoadingSessions: Bool { get }
    
    // MARK: - Sessions Management
    var sessions: [GameSession] { get }
    var visibleSessions: [GameSession] { get }
    func loadSessions() async throws
    
    // MARK: - Session Management
    func loadSession(_ session: GameSession) async throws
    func loadSessionById(_ id: UUID) async throws
    func startNewSession(mountain: Mountain, players: [Player]) async throws -> GameSession
    func deleteSession() async throws
    
    // MARK: - Score Management
    func addScore(_ score: Score) async throws
    func deleteScore(_ score: Score) async throws
    
    // MARK: - Player Management
    var players: [Player] { get }
    var scores: [Score] { get }
    var mountain: Mountain? { get }
    
    // MARK: - Leaderboard
    var leaderboardSummaries: [LeaderboardSummary] { get }
    var filteredScores: [Score] { get }
    func loadLeaderboard() async throws
    func updateLeaderboard() async throws
}
