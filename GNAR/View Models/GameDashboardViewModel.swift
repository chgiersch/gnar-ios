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
final class GameDashboardViewModel: ObservableObject {
    @Published var session: GameSession
    @Published var scoreSummaries: [ScoreSummary] = []
    @Published var scores: [Score] = []
    @Published var showingScoreEntry = false
    @Published var selectedPlayer: Player?

    let persistenceController: PersistenceController

    var sortedPlayers: [Player] {
        let scoresByPlayerID = Dictionary(grouping: scores, by: { $0.playerID })

        // Attach score totals to each player
        let scoredPlayers = session.playersArray.map { player -> (Player, Int) in
            let playerScores = scoresByPlayerID[player.id ?? UUID()] ?? []
            let total = playerScores.reduce(0) { $0 + $1.proScore }
            return (player, total)
        }

        let allZero = scoredPlayers.allSatisfy { $0.1 == 0 }

        if allZero {
            return scoredPlayers.map { $0.0 }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } else {
            return scoredPlayers
                .sorted { $0.1 > $1.1 }
                .map { $0.0 }
        }
    }

    var filteredScores: [Score] {
        guard let selected = selectedPlayer else { return [] }
        return scores.filter { $0.playerID == selected.id }
    }

    init(session: GameSession, persistenceController: PersistenceController = .shared) {
        self.session = session
        self.persistenceController = persistenceController
        self.selectedPlayer = session.playersArray.first
        print("📊 GameDashboardViewModel initialized with session ID: \(session.id?.uuidString ?? "unknown")")
        print("📅 Session start date: \(session.startDate ?? Date())")
        print("🏔️ Mountain name: \(session.mountainName)")
        print("👥 Players count: \(session.players?.count ?? 0)")
        print("📈 Scores count: \(session.scores?.count ?? 0)")
    }

    func loadScores() async {
        let context = persistenceController.container.viewContext
        
        do {
            let start = Date()
            print("🔄 Fetching scores for session \(session.id?.uuidString ?? "unknown")")
            let request: NSFetchRequest<Score> = Score.fetchRequest()
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(Score.gameSession), session)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Score.timestamp, ascending: false)]
            request.returnsObjectsAsFaults = false
            let rawScores = try await context.perform {
                try context.fetch(request)
            }
            let end = Date()
            print("✅ Fetched \(rawScores.count) scores in \(end.timeIntervalSince(start)) seconds.")

            self.scores = rawScores
            self.scoreSummaries = rawScores.map { score in
                let id = score.id ?? UUID()
                let points = Score.calculateProScore(from: score)
                let lineName = score.lineScore?.lineWorth?.name
                let snowLevel = SnowLevel(rawValue: score.lineScore?.snowLevel ?? "")
                print("📝 Creating ScoreSummary for score ID: \(id), points: \(points), lineName: \(lineName ?? "Unknown"), snowLevel: \(snowLevel?.rawValue ?? "Unknown")")
                return ScoreSummary(id: id, lineName: lineName, snowLevel: snowLevel, points: points)
            }
            print("✅ Updated scoreSummaries with \(self.scoreSummaries.count) summaries")
        } catch {
            print("Failed to fetch scores: \(error)")
        }
    }

    func addScore(_ score: Score) {
        print("➕ Adding score: \(score.id?.uuidString ?? "unknown") with points: \(score.proScore)")
        scores.insert(score, at: 0)
        print("📊 Current scores count: \(scores.count)")
        session.addToScores(score)
        print("🔗 Added score to session: \(session.id?.uuidString ?? "unknown")")
        persistenceController.saveContext()
        print("💾 Saved context after adding score")
        
        /// Call loadScores to refresh the scores and score summaries
        Task {
            await loadScores()
        }
    }
    
    var leaderboardSummaries: [LeaderboardSummary] {
        let scoresByPlayerID = Dictionary(grouping: scores, by: { $0.playerID })

        return session.playersArray.map { player in
            let playerScores = scoresByPlayerID[player.id ?? UUID()] ?? []

            let proTotal = playerScores.reduce(0) { $0 + $1.proScore }
            let gnarTotal = playerScores.reduce(0) { $0 + $1.gnarScore }

            return LeaderboardSummary(
                id: player.id ?? UUID(),
                player: player,
                proScore: proTotal,
                gnarScore: gnarTotal
            )
        }
        .sorted {
            if $0.proScore == $1.proScore {
                return $0.player.name.localizedCaseInsensitiveCompare($1.player.name) == .orderedAscending
            } else {
                return $0.proScore > $1.proScore
            }
        }
    }
}
