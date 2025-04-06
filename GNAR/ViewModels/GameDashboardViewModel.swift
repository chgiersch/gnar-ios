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
    }

    var sortedPlayers: Set<Player> {
        session.players as! Set<Player>
    }

    func loadScores() async {
        let context = persistenceController.container.viewContext

        do {
            let request: NSFetchRequest<Score> = Score.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Score.timestamp, ascending: false)]
            let rawScores = try await context.perform {
                try context.fetch(request)
            }

            self.scores = rawScores
            self.scoreSummaries = rawScores.map { score in
                let id = score.id ?? UUID()
                let points = Score.calculateProScore(from: score)
                let lineName = score.lineScore?.lineWorth?.name
                return ScoreSummary(id: id, lineName: lineName, points: points)
            }
        } catch {
            print("Failed to fetch scores: \(error)")
        }
    }

    func addScore(_ score: Score) {
        scores.insert(score, at: 0)
        session.addToScores(score)
        persistenceController.saveContext()
    }
}
