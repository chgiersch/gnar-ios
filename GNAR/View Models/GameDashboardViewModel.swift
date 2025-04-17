//
//  GameDashboardViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


// GameDashboardViewModel.swift

import Foundation
import SwiftUI
import CoreData

@MainActor
class GameDashboardViewModel: ObservableObject {
    // MARK: - Properties
    
    let session: GameSession
    let viewContext: NSManagedObjectContext
    
    @Published var scores: [Score] = []
    @Published var selectedPlayer: Player?
    @Published var error: Error?
    @Published var leaderboardSummaries: [LeaderboardSummary] = []
    
    // MARK: - Initialization
    
    init(session: GameSession, viewContext: NSManagedObjectContext) {
        self.session = session
        self.viewContext = viewContext
        self.selectedPlayer = session.playersArray.first
        Task {
            await loadScores()
            await loadLeaderboard()
        }
    }
    
    // MARK: - Score Management
    
    func loadScores() async {
        do {
            let request = Score.fetchRequest()
            request.predicate = NSPredicate(format: "gameSession == %@", session)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Score.timestamp, ascending: true)]
            scores = try await viewContext.fetch(request)
        } catch {
            self.error = error
        }
    }
    
    func deleteScore(_ score: Score) async {
        do {
            viewContext.delete(score)
            try viewContext.save()
            await loadScores()
            await loadLeaderboard()
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Player Management
    
    func selectPlayer(_ player: Player) {
        selectedPlayer = player
    }
    
    func clearSelectedPlayer() {
        selectedPlayer = nil
    }
    
    // MARK: - Leaderboard
    
    var filteredScores: [Score] {
        guard let selected = selectedPlayer else { return [] }
        return scores.filter { $0.player == selected }
    }
    
    func loadLeaderboard() async {
        await updateLeaderboard()
    }
    
    private func updateLeaderboard() {
        let players = session.playersArray
        var summaries: [LeaderboardSummary] = []
        
        // Sort players by their scores in this game session
        let sortedPlayers = players.sorted { (player1: Player, player2: Player) in
            let player1Scores = session.scoresArray.filter { $0.player?.id == player1.id }
            let player2Scores = session.scoresArray.filter { $0.player?.id == player2.id }
            
            let player1Total = player1Scores.reduce(0) { $0 + $1.gnarScore }
            let player2Total = player2Scores.reduce(0) { $0 + $1.gnarScore }
            
            // First sort by gnarScore
            if player1Total != player2Total {
                return player1Total > player2Total
            }
            
            // If scores are equal, sort by name
            return player1.name < player2.name
        }
        
        // Create summaries with ranks
        for (index, player) in sortedPlayers.enumerated() {
            let rank = index + 1
            let summary = LeaderboardSummary(player: player, gameSession: session, rank: rank)
            summaries.append(summary)
        }
        
        self.leaderboardSummaries = summaries
    }
}
