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
    let onEdit: () -> Void
    let onDelete: () -> Void
    let session: GameSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(score.playerName(in: session))
                    .font(.subheadline.bold())
                Spacer()
                Text("\(score.proScore) pts")
                    .font(.subheadline)
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    if let line = score.lineScore {
                        ScorePill(title: "Line", points: line.points)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(score.trickBonusScoresArray, id: \.self) { trickScore in
                            if let trick = trickScore.trickBonus {
                                ScorePill(title: trick.name, points: Int(trickScore.points))
                            }
                        }

                        ForEach(score.ecpScoresArray, id: \.self) { ecpScore in
                            if let ecp = ecpScore.ecp {
                                ScorePill(title: ecp.name, points: Int(ecpScore.points))
                            }
                        }

                        ForEach(score.penaltyScoresArray, id: \.self) { penaltyScore in
                            if let penalty = penaltyScore.penalty {
                                ScorePill(title: penalty.name, points: Int(penaltyScore.points))
                            }
                        }
                    }

                    HStack {
                        Spacer()
                        Button(role: .destructive) { onDelete() } label: {
                            Image(systemName: "trash")
                        }
                        Button { onEdit() } label: {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.opacity)
            }
        }
        .padding(.vertical, 6)
    }
}

struct ScorePill: View {
    let title: String
    let points: Int?

    var body: some View {
        if let points = points {
            Text("\(title): \(points)")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.15))
                .clipShape(Capsule())
        }
    }
}
