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
    
    init(session: GameSession) {
        _viewModel = StateObject(wrappedValue: GameDashboardViewModel(session: session))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    LeaderboardSection(players: viewModel.sortedPlayers)
                    ScoreHistorySection(scoreSummaries: viewModel.scoreSummaries)
                }
            }
            .navigationTitle("Game: \(viewModel.session.mountainName)")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.loadScores() }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("End") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingScoreEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("AddScoreButton")
                }
            }
            .sheet(isPresented: $viewModel.showingScoreEntry) {
                ScoreEntryView(
                    playerName: "You",
                    context: viewModel.persistenceController.container.viewContext,
                    isFreeRange: viewModel.session.mountainName == "Free Range"
                ) { newScore in
                    viewModel.addScore(newScore)
                }
            }
        }
    }
}

struct LeaderboardSection: View {
    let players: Set<Player>
    
    var body: some View {
        Section("Leaderboard") {
            ForEach(Array(players)) { player in
                VStack(alignment: .leading) {
                    Text(player.name)
                        .font(.headline)
                    HStack {
                        Text("GNAR: \(player.gnarScore)")
                        Spacer()
                        Text("Pro: \(player.proScore)")
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct ScoreHistorySection: View {
    let scoreSummaries: [ScoreSummary]
    
    var body: some View {
        Section("Score History") {
            ForEach(scoreSummaries) { summary in
                ScoreHistoryRow(summary: summary)
            }
        }
    }
}

struct ScoreHistoryRow: View {
    let summary: ScoreSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let lineName = summary.lineName {
                    Text(lineName)
                        .font(.headline)
                } else {
                    Text("Unknown Line")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Text("Points: \(summary.points)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(summary.points)")
                .font(.title2)
                .bold()
        }
        .padding(.vertical, 4)
    }
}

struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .clipShape(Capsule())
    }
}
