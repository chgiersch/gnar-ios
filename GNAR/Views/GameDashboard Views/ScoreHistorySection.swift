//
//  ScoreHistorySection.swift
//  GNAR
//
//  Created by Chris Giersch on 4/9/25.
//


import SwiftUI

struct ScoreHistorySection: View {
    @ObservedObject var viewModel: GameDashboardViewModel
    let scores: [Score]
    @Binding var expandedScoreIDs: Set<UUID>
    let onEdit: (Score) -> Void

    var body: some View {
        Section("Score History") {
            ForEach(scores) { score in
                ScoreHistoryRow(
                    score: score,
                    isExpanded: expandedScoreIDs.contains(score.id!),
                    onTap: {
                        withAnimation {
                            toggleExpansion(for: score.id!)
                        }
                    },
                    onEdit: { onEdit(score) },
                    onDelete: { viewModel.deleteScore(score) },
                    session: viewModel.session
                )
            }
        }
    }

    private func toggleExpansion(for id: UUID) {
        if expandedScoreIDs.contains(id) {
            expandedScoreIDs.remove(id)
        } else {
            expandedScoreIDs.insert(id)
        }
    }
}
