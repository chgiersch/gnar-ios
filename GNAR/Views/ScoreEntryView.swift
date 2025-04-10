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
    @State private var isShowingLineWorthPicker = false
    @State private var isShowingTrickPicker = false
    @State private var isShowingECPPicker = false
    @State private var isShowingPenaltyPicker = false
    
    @Binding var selectedPlayerID: NSManagedObjectID
    let allPlayers: [Player]
    
    let onScoreAdded: (Score) -> Void
    let isFreeRange: Bool
    
    init(
        selectedPlayerID: Binding<NSManagedObjectID>,
        allPlayers: [Player],
        session: GameSession,
        context: NSManagedObjectContext,
        isFreeRange: Bool,
        editingScore: Score? = nil,
        onScoreAdded: @escaping (Score) -> Void
    ) {
        let vm = ScoreEntryViewModel(session: session, context: context)
        if let editing = editingScore {
            vm.load(from: editing)
        }

        _viewModel = StateObject(wrappedValue: vm)
        self._selectedPlayerID = selectedPlayerID
        self.allPlayers = allPlayers
        self.onScoreAdded = onScoreAdded
        self.isFreeRange = isFreeRange
    }

    private var headerSection: some View {
        Section("Scoring For") {
            Picker("Player", selection: $selectedPlayerID) {
                ForEach(allPlayers) { player in
                    Text(player.name).tag(player.objectID)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var lineWorthSection: some View {
        if let line = viewModel.selectedLineScore {
            return AnyView(Section("Line Worth") {
                HStack {
                    HStack {
                        if let lineWorth = line.lineWorth {
                            Text(lineWorth.name)
                                .font(.headline)
                        } else {
                            Text("No Line Worth")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(viewModel.points(for: line.lineWorth!, snowLevel: SnowLevel(rawValue: line.snowLevel!)!))")
                            .foregroundColor(SnowLevel(rawValue: line.snowLevel!)?.displayColor ?? .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isShowingLineWorthPicker = true
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

    private var tricksSection: some View {
        if !viewModel.selectedTricks.isEmpty {
            return AnyView(Section("Tricks") {
                ForEach(Array(viewModel.selectedTricks.enumerated()), id: \.offset) { index, trick in
                    HStack {
                        Text(trick.name)
                        Spacer()
                        Text("\(trick.points)")
                        Button(action: { viewModel.removeTrick(at: index) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            })
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private var ecpsSection: some View {
        if !viewModel.selectedECPs.isEmpty {
            return AnyView(Section("ECPs") {
                ForEach(Array(viewModel.selectedECPs.enumerated()), id: \.offset) { index, ecp in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(ecp.name)
                            Text(ecp.descriptionText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(ecp.points)")
                        Button(action: { viewModel.removeECP(at: index) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            })
        } else {
            return AnyView(EmptyView())
        }
    }

    private var penaltiesSection: some View {
        if !viewModel.selectedPenalties.isEmpty {
            return AnyView(Section("Penalties") {
                ForEach(Array(viewModel.selectedPenalties.enumerated()), id: \.offset) { index, penalty in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(penalty.name)
                            Text("\(penalty.points)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        Spacer()
                        Button(action: { viewModel.removePenalty(at: index) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            })
        } else {
            return AnyView(EmptyView())
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    headerSection
                    if !isFreeRange {
                        lineWorthSection
                    }
                    tricksSection
                    ecpsSection
                    penaltiesSection
                }
                // MARK: - Quick Action Buttons
                HStack(spacing: 20) {
                    if !isFreeRange {
                        RoundScoreButton(title: "Line", systemImage: "mountain.2.fill") {
                            isShowingLineWorthPicker = true
                        }
                    }
                    RoundScoreButton(title: "Trick", systemImage: "figure.skiing.downhill") {
                        isShowingTrickPicker = true
                    }
                    RoundScoreButton(title: "ECP", systemImage: "star.fill") {
                        isShowingECPPicker = true
                    }
                    RoundScoreButton(title: "Penalty", systemImage: "exclamationmark.triangle.fill") {
                        isShowingPenaltyPicker = true
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle(viewModel.editingScore == nil ? "New Score" : "Edit Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Claim") {
                        print("Attempting to add score...")
                        if let selectedPlayer = allPlayers.first(where: { $0.objectID == selectedPlayerID }) {
                            let score = viewModel.saveScore(for: selectedPlayer)
                            onScoreAdded(score)
                        }
                        dismiss()
                    }
                }
            }

            // MARK: - Picker Sheets
            .sheet(isPresented: $isShowingLineWorthPicker) {
                LineWorthPickerView(
                    context: viewModel.context,
                    selectedLineWorth: viewModel.selectedLineScore?.lineWorth,
                    selectedSnowLevel: viewModel.selectedLineScore?.snowLevel.flatMap(SnowLevel.init) ?? .medium
                ) { selectedLineWorth, selectedSnowLevel in
                    let newLineScore = LineScore.create(
                        in: viewModel.context,
                        lineWorth: selectedLineWorth,
                        snowLevel: selectedSnowLevel
                    )
                    viewModel.selectedLineScore = newLineScore
                    isShowingLineWorthPicker = false
                }
            }
            .sheet(isPresented: $isShowingTrickPicker) {
                TrickBonusPickerView(
                    allTrickBonuses: viewModel.fetchTrickBonuses(),
                    selectedBonuses: $viewModel.selectedTricks
                )
            }

            .sheet(isPresented: $isShowingECPPicker) {
                ECPPickerView(
                    allECPs: viewModel.fetchECPs(),
                    selectedECPs: $viewModel.selectedECPs
                )
            }

            .sheet(isPresented: $isShowingPenaltyPicker) {
                PenaltyPickerView(
                    allPenalties: viewModel.fetchPenalties(),
                    selectedPenalties: $viewModel.selectedPenalties
                )
            }
        }
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


