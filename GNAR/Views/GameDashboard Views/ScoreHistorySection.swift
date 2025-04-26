//
//  ScoreHistorySection.swift
//  GNAR
//
//  Created by Chris Giersch on 4/9/25.
//


import SwiftUI

/// Section for displaying score history with expandable rows
struct ScoreHistorySection: View {
    @ObservedObject var viewModel: GameDashboardViewModel
    var scores: [Score]
    @Binding var expandedScoreIDs: Set<UUID>
    @State private var errorMessage: String? = nil

    var body: some View {
        Section("Score History") {
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.vertical, 4)
            }
            
            ForEach(sortedScores, id: \.self) { score in
                ScoreHistoryRow(
                    score: score,
                    isExpanded: expandedScoreIDs.contains(score.id),
                    onTap: {
                        withAnimation {
                            toggleExpansion(for: score.id)
                        }
                    },
                    onDelete: {
                        Task {
                            do {
                                try await viewModel.deleteScore(score)
                            } catch {
                                handleError(error)
                            }
                        }
                    },
                    session: viewModel.session
                )
                .transition(.opacity)
            }
            .onDelete { indexSet in
                Task {
                    for index in indexSet {
                        let score = sortedScores[index]
                        do {
                            try await viewModel.deleteScore(score)
                        } catch {
                            handleError(error)
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: scores.count)
    }

    /// Returns scores sorted by timestamp, newest first
    private var sortedScores: [Score] {
        scores.sorted { (score1, score2) -> Bool in
            guard let date1 = score1.timestamp, let date2 = score2.timestamp else {
                return false
            }
            return date1 > date2
        }
    }

    /// Toggles the expansion state of a score row
    private func toggleExpansion(for id: UUID) {
        if expandedScoreIDs.contains(id) {
            expandedScoreIDs.remove(id)
        } else {
            expandedScoreIDs.insert(id)
        }
    }
    
    /// Handles errors that may occur during score deletion
    private func handleError(_ error: Error) {
        errorMessage = "Failed to delete score: \(error.localizedDescription)"
        
        // Clear error message after 3 seconds
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            errorMessage = nil
        }
    }
}
