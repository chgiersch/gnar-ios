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
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .padding()
                    Text("Loading game data...")
                }
            } else {
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
                .animation(.easeInOut, value: viewModel.filteredScores.count)
                .onChange(of: viewModel.selectedPlayer) { oldValue, newValue in
                    print("GameDashboardView: selectedPlayer changed from \(oldValue?.name ?? "nil") to \(newValue?.name ?? "nil")")
                }
            }
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .navigationTitle(viewModel.gameState?.currentSession?.mountain.name ?? "Game")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Exit") {
                    dismiss()
                }
                .accessibilityIdentifier("EndGameButton")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        if await viewModel.prepareScoreEntry() {
                            showingScoreEntry = true
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(viewModel.selectedPlayer == nil || !viewModel.isSessionLoaded)
                .accessibilityIdentifier("AddScoreButton")
            }
        }
        .sheet(isPresented: $showingScoreEntry) {
            if let scoreViewModel = viewModel.scoreEntryViewModel {
                ScoreEntryView(viewModel: scoreViewModel)
                    .onChange(of: scoreViewModel.didSaveScore) { oldValue, newValue in
                        if newValue {
                            scoreViewModel.didSaveScore = false
                        }
                    }
            } else {
                VStack {
                    ProgressView()
                        .padding()
                    Text("Loading score data...")
                }
                .onAppear {
                    Task {
                        await viewModel.prepareScoreEntry()
                    }
                }
            }
        }
    }
}
