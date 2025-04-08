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
    @Published var showingScoreEntry = false
    @Published var scores: [Score] = []
    @Published var scoreSummaries: [ScoreSummary] = []

    let persistenceController: PersistenceController

    init(session: GameSession, persistenceController: PersistenceController = .shared) {
        self.session = session
        self.persistenceController = persistenceController
        print("📊 GameDashboardViewModel initialized with session ID: \(session.id?.uuidString ?? "unknown")")
        print("📅 Session start date: \(session.startDate ?? Date())")
        print("🏔️ Mountain name: \(session.mountainName)")
        print("👥 Players count: \(session.players?.count ?? 0)")
        print("📈 Scores count: \(session.scores?.count ?? 0)")
    }

    var sortedPlayers: Set<Player> {
        session.players as! Set<Player>
    }

    func loadScores() async {
        let context = persistenceController.container.viewContext
        
        do {
            let start = Date()
            print("🔄 Fetching scores for session \(session.id?.uuidString ?? "unknown")")
            let request: NSFetchRequest<Score> = Score.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Score.timestamp, ascending: false)]
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
}
