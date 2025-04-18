import Foundation
import CoreData

/// Data model for displaying a player's score summary in the leaderboard for a specific game session
struct LeaderboardSummary: Identifiable {
    var id: UUID
    var player: Player?
    var playerName: String
    var gnarScore: Int
    var proScore: Int
    var rank: Int
    
    init(player: Player, gameSession: GameSession, rank: Int = 0) {
        self.id = player.id
        self.player = player
        self.playerName = player.name
        
        // Calculate scores for this specific game session
        let gameScores = gameSession.scoresArray.filter { $0.player?.id == player.id }
        self.gnarScore = Int(gameScores.reduce(0) { $0 + $1.gnarScore })
        self.proScore = Int(gameScores.reduce(0) { $0 + $1.proScore })
        self.rank = rank
    }
} 
