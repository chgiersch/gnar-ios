//
//  GameDashboardView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/31/25.
//


import SwiftUI

struct GameDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GameDashboardViewModel
    @State private var expandedScoreIDs: Set<UUID> = []
    @State private var showingScoreEntry = false
    
    init(viewModel: GameDashboardViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Leaderboard Section
                LeaderboardSection(
                    summaries: viewModel.leaderboardSummaries,
                    selectedPlayer: $viewModel.selectedPlayer
                )
                
                // Score History Section
                ScoreHistorySection(
                    viewModel: viewModel,
                    scores: viewModel.filteredScores,
                    expandedScoreIDs: $expandedScoreIDs
                )
            }
            .navigationTitle(viewModel.session.mountainName)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("End Game") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingScoreEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(viewModel.selectedPlayer == nil)
                }
            }
            .sheet(isPresented: $showingScoreEntry) {
                if let selectedPlayer = viewModel.selectedPlayer {
                    ScoreEntryView(
                        viewContext: viewContext,
                        selectedPlayer: selectedPlayer,
                        gameSession: viewModel.session,
                        onDismiss: {
                            showingScoreEntry = false
                            Task {
                                await viewModel.loadScores()
                                await viewModel.loadLeaderboard()
                            }
                        }
                    )
                }
            }
        }
    }
}
