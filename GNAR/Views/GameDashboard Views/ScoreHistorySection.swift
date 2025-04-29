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
                                print("🗑️ ScoreHistorySection: Attempting to soft delete score \(score.id)")
                                try await viewModel.deleteScore(score)
                                print("✅ ScoreHistorySection: Successfully soft deleted score \(score.id)")
                            } catch {
                                print("❌ ScoreHistorySection: Failed to soft delete score \(score.id): \(error)")
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
                    // Delete in reverse order to maintain correct indices
                    for index in indexSet.reversed() {
                        let score = sortedScores[index]
                        print("🗑️ ScoreHistorySection: Swipe soft deleting score \(score.id)")
                        do {
                            try await viewModel.deleteScore(score)
                            print("✅ ScoreHistorySection: Successfully swipe soft deleted score \(score.id)")
                        } catch {
                            print("❌ ScoreHistorySection: Failed to swipe soft delete score \(score.id): \(error)")
                            handleError(error)
                            break  // Stop deleting if we hit an error
                        }
                    }
                }
            }
        }
        .onAppear() {
            printScores() // Debugging line to print scores
        }
    }

    /// Returns scores sorted by timestamp, newest first
    var sortedScores: [Score] {
        let nonDeletedScores = scores.filter { !$0.isSoftDeleted }
        print("📊 ScoreHistory: \(nonDeletedScores.count) active scores")
        return nonDeletedScores.sorted { $0.createdAt > $1.createdAt }
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
    
    
    // TODO: Remove this function after debugging
    func printScores() {
        print("ScoreHistorySection - scores: \(scores)")
    }
}
