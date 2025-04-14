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
final class GameDashboardViewModel: ObservableObject {
    @Published var session: GameSession
    @Published var scoreSummaries: [ScoreSummary] = []
    @Published var scores: [Score] = []
    @Published var showingScoreEntry = false
    @Published var selectedPlayer: Player?

    private let scoreRepository: ScoreRepository
    
    var scoreRepositoryViewContext: NSManagedObjectContext {
        scoreRepository.viewContext
    }

    var sortedPlayers: [Player] {
        let scoresByPlayerID = Dictionary(grouping: scores, by: { $0.playerID })
        let scoredPlayers = session.playersArray.map { player in
            let total = scoresByPlayerID[player.id ?? UUID()]?.reduce(0) { $0 + $1.proScore } ?? 0
            return (player, total)
        }

        let allZero = scoredPlayers.allSatisfy { $0.1 == 0 }

        return allZero
            ? scoredPlayers.map { $0.0 }.sorted { $0.name < $1.name }
            : scoredPlayers.sorted { $0.1 > $1.1 }.map { $0.0 }
    }

    var filteredScores: [Score] {
        guard let selected = selectedPlayer else { return [] }
        return scores.filter { $0.playerID == selected.id }
    }

    init(session: GameSession, repository: ScoreRepository) {
        self.session = session
        self.scoreRepository = repository
        self.selectedPlayer = session.playersArray.first
    }

    func loadScores() async {
        do {
            let rawScores = try await scoreRepository.fetchScores(for: session)
            self.scores = rawScores
            self.scoreSummaries = rawScores.map { score in
                ScoreSummary(
                    id: score.id ?? UUID(),
                    lineName: score.lineScore?.lineWorth?.name,
                    snowLevel: SnowLevel(rawValue: score.lineScore?.snowLevel ?? ""),
                    points: Score.calculateProScore(from: score)
                )
            }
        } catch {
            print("❌ Failed to fetch scores: \(error)")
        }
    }

    func addScore(_ score: Score) {
        do {
            try scoreRepository.addScore(score, to: session)
            Task { await loadScores() }
        } catch {
            print("❌ Failed to add score: \(error)")
        }
    }

    func deleteScore(_ score: Score) {
        do {
            try scoreRepository.deleteScore(score)
            Task { await loadScores() }
        } catch {
            print("❌ Failed to delete score: \(error)")
        }
    }

    var leaderboardSummaries: [LeaderboardSummary] {
        let scoresByPlayerID = Dictionary(grouping: scores, by: { $0.playerID })

        return session.playersArray.map { player in
            let playerScores = scoresByPlayerID[player.id ?? UUID()] ?? []
            return LeaderboardSummary(
                id: player.id ?? UUID(),
                player: player,
                proScore: playerScores.reduce(0) { $0 + $1.proScore },
                gnarScore: playerScores.reduce(0) { $0 + $1.gnarScore }
            )
        }
        .sorted {
            $0.proScore == $1.proScore
                ? $0.player.name < $1.player.name
                : $0.proScore > $1.proScore
        }
    }
}
