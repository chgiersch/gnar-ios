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
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    LeaderboardSection(summaries: viewModel.leaderboardSummaries,
                                       selectedPlayer: $viewModel.selectedPlayer)
                    ScoreHistorySection(scores: viewModel.filteredScores)
                }
                .navigationTitle("Game: \(viewModel.session.mountainName)")
                .navigationBarTitleDisplayMode(.inline)
                .task { await viewModel.loadScores() }
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
                        .accessibilityIdentifier("AddScoreButton")
                    }
                }
                .sheet(isPresented: $viewModel.showingScoreEntry) {
                    if let selectedPlayer = viewModel.selectedPlayer {
                        let selectedPlayerID = selectedPlayer.objectID
                        ScoreEntryView(
                            selectedPlayerID: .constant(selectedPlayerID), /// not ideal for updating, but safe
                            allPlayers: viewModel.sortedPlayers,
                            session: viewModel.session,
                            context: viewModel.persistenceController.container.viewContext,
                            isFreeRange: viewModel.session.mountainName == "Free Range"
                        ) { newScore in
                            viewModel.addScore(newScore)
                        }
                    }
                }
            }
        }
    }
}

struct LeaderboardSection: View {
    let summaries: [LeaderboardSummary]
    @Binding var selectedPlayer: Player?

    var body: some View {
        Section("Leaderboard") {
            ForEach(summaries) { summary in
                let player = summary.player
                Button(action: {
                    selectedPlayer = player
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.name)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            HStack(spacing: 12) {
                                Label("GNAR: \(summary.gnarScore)", systemImage: "sparkles")
                                Spacer()
                                Label("Pro: \(summary.proScore)", systemImage: "bolt.fill")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedPlayer?.id == player.id ? Color.accentColor.opacity(0.15) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ScoreHistorySection: View {
    let scores: [Score]
    
    var body: some View {
        Section("Score History") {
            if scores.isEmpty {
                Text("No scores yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(scores, id: \.id) { score in
                    ScoreRowView(score: score)
                }
            }
        }
    }
}

struct ScoreRowView: View {
    let score: Score
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 🏔️ Line Info
            if let lineScore = score.lineScore,
               let line = lineScore.lineWorth {
                HStack {
                    Text("🎿 \(line.name)")
                        .font(.headline)
                    Spacer()
                    Text("\(lineScore.points) pts")
                        .bold()
                }
                
                if let level = SnowLevel(rawValue: lineScore.snowLevel ?? "") {
                    Text("Snow: \(level.rawValue.capitalized)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // ✨ Trick Bonuses
            if let trickScores = score.trickBonusScores?.allObjects as? [TrickBonusScore], !trickScores.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tricks:")
                        .font(.subheadline)
                        .bold()
                    ForEach(trickScores, id: \.self) { ts in
                        if let trick = ts.trickBonus {
                            Text("- \(trick.name) (\(trick.points) pts)")
                                .font(.caption)
                        }
                    }
                }
            }
            
            // 🌟 ECPs
            if let ecpScores = score.ecpScores?.allObjects as? [ECPScore], !ecpScores.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ECPs:")
                        .font(.subheadline)
                        .bold()
                    ForEach(ecpScores, id: \.self) { es in
                        if let ecp = es.ecp {
                            Text("- \(ecp.name) (\(ecp.points) pts)")
                                .font(.caption)
                        }
                    }
                }
            }
            
            // ⚠️ Penalties
            if let penaltyScores = score.penaltyScores?.allObjects as? [PenaltyScore], !penaltyScores.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Penalties:")
                        .font(.subheadline)
                        .bold()
                    ForEach(penaltyScores, id: \.self) { ps in
                        if let penalty = ps.penalty {
                            Text("- \(penalty.name) (\(penalty.points) pts)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            // 🕒 Timestamp
            if let date = score.timestamp {
                Text("Logged: \(date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 6)
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
