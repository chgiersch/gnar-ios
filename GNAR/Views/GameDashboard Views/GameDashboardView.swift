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
    @State private var showCelebration = false
    @State private var celebrationScore = 0
    @State private var previousScoreCount = 0
    
    init(viewModel: GameDashboardViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Leaderboard Section
                LeaderboardSection(
                    summaries: viewModel.leaderboardSummaries,
                    selectedPlayer: $viewModel.selectedPlayer,
                    showCelebration: showCelebration,
                    celebrationScore: celebrationScore,
                    onCelebrationComplete: { showCelebration = false }
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
                    .accessibilityIdentifier("EndGameButton")
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingScoreEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(viewModel.selectedPlayer == nil)
                    .accessibilityIdentifier("AddScoreButton")
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
            .onChange(of: viewModel.scores.count) { oldCount, newCount in
                // Trigger celebration when a new score is added (only if we have a selected player)
                if newCount > previousScoreCount,
                   let selectedPlayer = viewModel.selectedPlayer,
                   let lastScore = viewModel.scores.last,
                   lastScore.player?.id == selectedPlayer.id {
                    celebrationScore = Int(lastScore.gnarScore)
                    showCelebration = true
                }
                previousScoreCount = newCount
            }
            .onAppear {
                previousScoreCount = viewModel.scores.count
            }
        }
    }
}
