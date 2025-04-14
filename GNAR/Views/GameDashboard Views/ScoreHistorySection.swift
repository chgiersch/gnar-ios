//
//  ScoreHistorySection.swift
//  GNAR
//
//  Created by Chris Giersch on 4/9/25.
//


import SwiftUI

struct ScoreHistorySection: View {
    @ObservedObject var viewModel: GameDashboardViewModel
    var scores: [Score]
    @Binding var expandedScoreIDs: Set<UUID>

    var body: some View {
        Section("Score History") {
            ForEach(scores, id: \.self) { score in
                if let id = score.id {
                    ScoreHistoryRow(
                        score: score,
                        isExpanded: expandedScoreIDs.contains(id),
                        onTap: {
                            withAnimation {
                                toggleExpansion(for: id)
                            }
                        },
                        onDelete: { },
                        session: viewModel.session
                    )
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let score = scores[index]
                    viewModel.deleteScore(score)
                }
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
