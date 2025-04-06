//
//  ScoreEntryView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/31/25.
//


import SwiftUI
import CoreData

struct ScoreEntryView: View {
    @StateObject private var viewModel: ScoreEntryViewModel
    @Environment(\.dismiss) private var dismiss
    let onScoreAdded: (Score) -> Void
    let isFreeRange: Bool
    
    init(
        playerName: String,
        context: NSManagedObjectContext,
        isFreeRange: Bool,
        onScoreAdded: @escaping (Score) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: ScoreEntryViewModel(playerName: playerName, context: context))
        self.onScoreAdded = onScoreAdded
        self.isFreeRange = isFreeRange
    }

    init(viewModel: ScoreEntryViewModel, isFreeRange: Bool = false) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onScoreAdded = { _ in }
        self.isFreeRange = isFreeRange
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("Adding score for:")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(viewModel.playerName)
                .font(.title)
                .bold()
            Text("Total Points: \(viewModel.totalPoints)")
                .font(.headline)
        }
        .padding(.vertical)
    }
    
    private var lineWorthSection: some View {
        if let line = $viewModel.selectedLineScore.wrappedValue {
            return AnyView(Section("Line Worth") {
                HStack {
                    HStack {
                        if let lineWorth = line.lineWorth {
                            Text(lineWorth.name)
                                .font(.headline)
                        } else {
                            Text("No Line Worth")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(line.points)")
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.showLinePicker()
                    }
                    
                    Button(action: viewModel.removeLine) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            })
        } else {
            return AnyView(EmptyView())
        }
    }

    //    private var tricksSection: some View {
    //        if !viewModel.selectedTricks.isEmpty {
    //            return AnyView(Section("Tricks") {
    //                ForEach(Array(viewModel.selectedTricks.enumerated()), id: \.offset) { index, trick in
    //                    HStack {
    //                        Text(trick.name)
    //                        Spacer()
    //                        Text("\(trick.points)")
    //                        Button(action: { viewModel.removeTrick(at: index) }) {
    //                            Image(systemName: "trash")
    //                                .foregroundColor(.red)
    //                        }
    //                    }
    //                }
    //            })
    //        } else {
    //            return AnyView(EmptyView())
    //        }
    //    }
    //
    //    private var ecpsSection: some View {
    //        if !viewModel.selectedECPs.isEmpty {
    //            return AnyView(Section("ECPs") {
    //                ForEach(Array(viewModel.selectedECPs.enumerated()), id: \.offset) { index, ecpID in
    //                    if let ecp = mockECPs.first(where: { $0.id == ecpID }) {
    //                        HStack {
    //                            VStack(alignment: .leading) {
    //                                Text(ecp.name)
    //                                Text(ecp.descriptionText)
    //                                    .font(.caption)
    //                                    .foregroundColor(.secondary)
    //                            }
    //                            Spacer()
    //                            Text("\(ecp.points)")
    //                            Button(action: { viewModel.removeECP(at: index) }) {
    //                                Image(systemName: "trash")
    //                                    .foregroundColor(.red)
    //                            }
    //                        }
    //                    }
    //                }
    //            })
    //        } else {
    //            return AnyView(EmptyView())
    //        }
    //    }
    //
    //    private var penaltiesSection: some View {
    //        if !viewModel.selectedPenalties.isEmpty {
    //            return AnyView(Section("Penalties") {
    //                ForEach(Array(viewModel.selectedPenalties.enumerated()), id: \.offset) { index, penaltyID in
    //                    if let penalty = mockPenalties.first(where: { $0.id == penaltyID }) {
    //                        HStack {
    //                            VStack(alignment: .leading) {
    //                                Text(penalty.name)
    //                                Text("\(penalty.points)")
    //                                    .font(.caption)
    //                                    .foregroundColor(.red)
    //                            }
    //                            Spacer()
    //                            Button(action: { viewModel.removePenalty(at: index) }) {
    //                                Image(systemName: "trash")
    //                                    .foregroundColor(.red)
    //                            }
    //                        }
    //                    }
    //                }
    //            })
    //        } else {
    //            return AnyView(EmptyView())
    //        }
    //    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    headerSection
                    if isFreeRange {
                        lineWorthSection
                    }
                    //                    tricksSection
                    //                    ecpsSection
                    //                    penaltiesSection
                }
                
                HStack(spacing: 20) {
                    if !isFreeRange {
                        RoundScoreButton(title: "Line", systemImage: "mountain.2.fill") {
                            viewModel.showLinePicker()
                        }
                    }
                    RoundScoreButton(title: "Trick", systemImage: "figure.skiing.downhill") {
                        viewModel.showTrickPicker()
                    }
                    RoundScoreButton(title: "ECP", systemImage: "star.fill") {
                        viewModel.showECPPicker()
                    }
                    RoundScoreButton(title: "Penalty", systemImage: "exclamationmark.triangle.fill") {
                        viewModel.showPenaltyPicker()
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("New Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Claim") {
                        let score = viewModel.addScore()
                        onScoreAdded(score)
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingLineWorthPicker) {
                LineWorthPickerView(
                    context: viewModel.context,
                    selectedLineWorth: viewModel.selectedLineScore?.lineWorth,
                    selectedSnowLevel: SnowLevel(rawValue: viewModel.selectedLineScore?.snowLevel ?? "") ?? .medium
                ) { lineWorth, snowLevel in
                    viewModel.selectedLineScore = LineScore.create(
                        in: viewModel.context,
                        lineWorth: lineWorth,
                        snowLevel: snowLevel.rawValue
                    )
                }
            }
            .sheet(isPresented: $viewModel.showingTrickPicker) {
                TrickBonusPickerView(
                    allTrickBonuses: viewModel.fetchTrickBonuses(),
                    selectedBonuses: $viewModel.selectedTricks
                )
            }
            .sheet(isPresented: $viewModel.showingECPPicker) {
                ECPPickerView(
                    allECPs: viewModel.fetchECPs(),
                    selectedECPs: $viewModel.selectedECPs
                )
            }
            .sheet(isPresented: $viewModel.showingPenaltyPicker) {
                PenaltyPickerView(
                    allPenalties: viewModel.fetchPenalties(),
                    selectedPenalties: $viewModel.selectedPenalties
                )
            }        }
    }
}

struct RoundScoreButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(Color.blue.opacity(0.2))
            .clipShape(Circle())
            .foregroundColor(.primary)
        }
    }
}


#Preview("Score Entry") {
    
}
