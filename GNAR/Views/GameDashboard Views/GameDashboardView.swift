//
//  GameDashboardView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/31/25.
//


import SwiftUI

struct GameDashboardView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: GameDashboardViewModel
    @State private var expandedScoreIDs: Set<UUID> = []
    
    init(session: GameSession, contexts: CoreDataContexts) {
        let repository = ScoreRepository(contexts: contexts)
        _viewModel = StateObject(wrappedValue: GameDashboardViewModel(session: session, repository: repository))
    }

    var body: some View {
        NavigationStack {
            List {
                LeaderboardSection(
                    summaries: viewModel.leaderboardSummaries,
                    selectedPlayer: $viewModel.selectedPlayer
                )

                ScoreHistorySection(
                    viewModel: viewModel,
                    scores: viewModel.filteredScores,
                    expandedScoreIDs: $expandedScoreIDs
                )
            }
            .navigationTitle("Game: \(viewModel.session.mountainName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Exit") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingScoreEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingScoreEntry) {
                if let player = viewModel.selectedPlayer {
                    ScoreEntryView(
                        selectedPlayerID: .constant(player.objectID),
                        allPlayers: viewModel.sortedPlayers,
                        session: viewModel.session,
                        context: viewModel.scoreRepositoryViewContext,
                        isFreeRange: viewModel.session.mountainName == "Free Range",
                        editingScore: nil
                    ) { newScore in
                        viewModel.addScore(newScore)
                    }
                }
            }
            .task {
                await viewModel.loadScores()
            }
        }
    }
}
