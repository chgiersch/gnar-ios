//
//  LeaderboardSection.swift
//  GNAR
//
//  Created by Chris Giersch on 4/9/25.
//


import SwiftUI

struct LeaderboardSection: View {
    let summaries: [LeaderboardSummary]
    @Binding var selectedPlayer: Player?
    let showCelebration: Bool
    let celebrationScore: Int
    let onCelebrationComplete: () -> Void

    var body: some View {
        Section("Leaderboard") {
            ForEach(summaries) { summary in
                let player = summary.player
                let isSelected = selectedPlayer?.id == player?.id
                
                Button {
                    selectedPlayer = player
                } label: {
                    HStack {
                        Text("\(summary.rank)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(summary.playerName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 12) {
                                Label("\(summary.gnarScore) pts", systemImage: "star.fill")
                                    .foregroundColor(.orange)
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
                            .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .celebrationOverlay(
                    show: showCelebration && isSelected,
                    score: celebrationScore,
                    onComplete: onCelebrationComplete
                )
            }
        }
    }
}
