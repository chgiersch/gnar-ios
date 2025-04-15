//
//  ScoreHistoryRow.swift
//  GNAR
//
//  Created by Chris Giersch on 4/9/25.
//


import SwiftUI

struct ScoreHistoryRow: View {
    let score: Score
    let isExpanded: Bool
    let onTap: () -> Void
    let onDelete: () async -> Void
    let session: GameSession

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                if let line = score.lineScore {
                    HStack {
                        Image(systemName: "mountain.2.fill")
                            .foregroundColor(.accentColor)

                        Text(line.lineWorth?.name ?? "Unknown Line")
                            .font(.subheadline.bold())
                        if isExpanded {
                            Spacer()
                            Text("\(Int(line.points)) pts")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        if score.ecpScores != nil {
                            Image(systemName: "skiing.downhill.fill")
                                .foregroundColor(.blue)
                        }
                        if score.trickBonusScores != nil {
                            Image(systemName: "star.fill")
                                .foregroundColor(.green)
                        }
                        if score.penaltyScores != nil {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }

                Spacer()

                if !isExpanded {
                    Text("\(score.proScore) pts")
                        .font(.subheadline)
                        .bold()
                        .padding(.leading, 8)
                }
            }

            /// Pills when collapsed: use multi-line wrap, not scroll
            if !isExpanded {
                PillWrapSection(items: score.trickBonusScoresArray.compactMap { $0.trickBonus?.name }, color: .blue)
                PillWrapSection(items: score.ecpScoresArray.compactMap { $0.ecp?.name }, color: .green)
                PillWrapSection(items: score.penaltyScoresArray.compactMap { $0.penalty?.name }, color: .red)
            }

            /// Fully expanded view
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    ScoreExpandedList(
                        icon: "figure.skiing.downhill",
                        color: .blue,
                        scores: score.trickBonusScoresArray.compactMap {
                            guard let trick = $0.trickBonus else { return nil }
                            return ScorePillData(title: trick.name, points: Int($0.points))
                        }
                    )

                    ScoreExpandedList(
                        icon: "star.fill",
                        color: .green,
                        scores: score.ecpScoresArray.compactMap {
                            guard let ecp = $0.ecp else { return nil }
                            return ScorePillData(title: ecp.name, points: Int($0.points))
                        }
                    )

                    ScoreExpandedList(
                        icon: "exclamationmark.triangle.fill",
                        color: .red,
                        scores: score.penaltyScoresArray.compactMap {
                            guard let penalty = $0.penalty else { return nil }
                            return ScorePillData(title: penalty.name, points: Int($0.points))
                        }
                    )
                    HStack {
                        Spacer()
                        Text("Total: \(score.proScore) pts")
                            .font(.subheadline)
                            .bold()
                    }
                }
                .padding(.top, 4)
                .transition(.opacity)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle()) /// Make full cell tappable
        .onTapGesture { onTap() } /// Toggle expansion
        .animation(.easeInOut, value: isExpanded)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task {
                    await onDelete()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

private struct PillLabel: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

/// Displays individually styled pills, wrapped using simple stacked HStacks.
/// This relies on visual line breaks (not automatic wrapping) for now.
private struct PillWrapSection: View {
    let items: [String]
    let color: Color

    var body: some View {
        let rows = makeRows(from: items)

        return VStack(alignment: .leading, spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { text in
                        Text(text)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(color.opacity(0.2))
                            .foregroundColor(color)
                            .clipShape(Capsule())
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    /// Breaks items into rows of up to 4
    private func makeRows(from items: [String]) -> [[String]] {
        var result: [[String]] = []
        var currentRow: [String] = []

        for item in items {
            currentRow.append(item)
            if currentRow.count == 4 {
                result.append(currentRow)
                currentRow = []
            }
        }

        if !currentRow.isEmpty {
            result.append(currentRow)
        }

        return result
    }
}

private struct ScoreExpandedList: View {
    let icon: String
    let color: Color
    let scores: [ScorePillData]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(scores) { item in
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .foregroundColor(color)
                        Text(item.title)
                            .font(.subheadline)
                            .foregroundColor(color)
                    }
                    Spacer()
                    Text("\(item.points)")
                        .font(.subheadline)
                }
            }
        }
    }
}

private struct ScorePillData: Identifiable {
    let id = UUID()
    let title: String
    let points: Int
}
