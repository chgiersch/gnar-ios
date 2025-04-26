//
//  ScoreEntryView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/31/25.
//


import SwiftUI
import CoreData

// Main ScoreEntryView - Now a container for smaller components
struct ScoreEntryView: View {
    @ObservedObject var viewModel: ScoreEntryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showLinesView = false
    @State private var showTricksView = false
    @State private var showECPsView = false
    @State private var showPenaltiesView = false

    var body: some View {
        NavigationStack {
            VStack {
                // Player header component
                PlayerHeaderView(viewModel: viewModel)
                
                // Score sections in ScrollView
                ScrollView {
                    VStack(spacing: 16) {
                        // Line section
                        if viewModel.currentSession?.mountain.name != "Free Range" {
                            LineSectionView(viewModel: viewModel)
                        }
                        
                        // Trick section
                        TrickSectionView(viewModel: viewModel)
                        
                        // ECP section
                        ECPSectionView(viewModel: viewModel)
                        
                        // Penalty section
                        PenaltySectionView(viewModel: viewModel)
                    }
                    .padding()
                }
                
                // Button toolbar component
                ScoreButtonToolbar(
                    viewModel: viewModel,
                    showLinesView: $showLinesView,
                    showTricksView: $showTricksView,
                    showECPsView: $showECPsView,
                    showPenaltiesView: $showPenaltiesView
                )
            }
            .navigationTitle("Score Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("CancelScoreButton")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.canAddScore {
                        Button("Add") {
                            Task {
                                do {
                                    try await viewModel.saveScore()
                                    dismiss()
                                } catch {
                                    print("Failed to save score: \(error)")
                                }
                            }
                        }
                        .accessibilityIdentifier("AddScoreButton")
                    }
                }
            }
            .sheet(isPresented: $showLinesView) {
                LineWorthPickerView(
                    context: viewModel.viewContext,
                    selectedLine: $viewModel.selectedLine,
                    selectedSnowLevel: $viewModel.selectedSnowLevel
                )
            }
            .sheet(isPresented: $showTricksView) {
                TrickBonusPickerView(
                    allTrickBonuses: viewModel.availableTricks,
                    selectedBonuses: $viewModel.selectedTricks
                )
            }
            .sheet(isPresented: $showECPsView) {
                ECPPickerView(
                    allECPs: viewModel.availableECPs,
                    selectedECPs: $viewModel.selectedECPs
                )
            }
            .sheet(isPresented: $showPenaltiesView) {
                PenaltyPickerView(
                    allPenalties: viewModel.availablePenalties,
                    selectedPenalties: $viewModel.selectedPenalties
                )
            }
        }
        .environment(\.managedObjectContext, viewModel.viewContext)
    }
}

// MARK: - Component Views

// 1. Player Header Component
struct PlayerHeaderView: View {
    @ObservedObject var viewModel: ScoreEntryViewModel
    
    var body: some View {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("PLAYER")
                                .font(.caption)
                                .foregroundColor(.secondary)
                    if let player = viewModel.gameState.selectedPlayer {
                        Text(player.name ?? "Unknown")
                            .font(.headline)
                    } else {
                        Text("No player selected")
                                .font(.headline)
                            .foregroundColor(.red)
                    }
                        }
                        Spacer()
                        if viewModel.selectedLine != nil {
                            VStack(alignment: .trailing) {
                                Text("TOTAL")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text(String(viewModel.currentScoreValue))
                                        .font(.system(size: 24, weight: .bold))
                                    Text("PTS")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding()
    }
}

// 2. Line Section Component
struct LineSectionView: View {
    @ObservedObject var viewModel: ScoreEntryViewModel
    
    var body: some View {
                            if viewModel.selectedLine != nil {
                                Section {
                                    VStack(alignment: .leading) {
                                        Text("LINE")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        if let line = viewModel.selectedLine {
                                            Text(line.name)
                                                .font(.headline)
                                        }
                                        
                                        Picker("Snow Level", selection: $viewModel.selectedSnowLevel) {
                                            ForEach(SnowLevel.allCases, id: \.self) { level in
                                                Text(level.displayName).tag(level)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                        }
}

// 3. Trick Section Component
struct TrickSectionView: View {
    @ObservedObject var viewModel: ScoreEntryViewModel
                        
    var body: some View {
                        if !viewModel.selectedTricks.isEmpty {
                            Section {
                                VStack(alignment: .leading) {
                                    Text("TRICK BONUS")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    ForEach(viewModel.selectedTricks, id: \.id) { trick in
                                        HStack {
                                            Text(trick.name)
                                                .font(.headline)
                                            Spacer()
                                            Text("\(trick.points) PTS")
                                                .font(.headline)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
    }
}
                        
// 4. ECP Section Component
struct ECPSectionView: View {
    @ObservedObject var viewModel: ScoreEntryViewModel
    
    var body: some View {
                        if !viewModel.selectedECPs.isEmpty {
                            Section {
                                VStack(alignment: .leading) {
                                    Text("EXTRA CREDIT POINTS")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    ForEach(viewModel.selectedECPs, id: \.id) { ecp in
                                        HStack {
                                            Text(ecp.name)
                                                .font(.headline)
                                            Spacer()
                                            Text("\(ecp.points) PTS")
                                                .font(.headline)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
    }
}
                        
// 5. Penalty Section Component
struct PenaltySectionView: View {
    @ObservedObject var viewModel: ScoreEntryViewModel
    
    var body: some View {
                        if !viewModel.selectedPenalties.isEmpty {
                            Section {
                                VStack(alignment: .leading) {
                                    Text("PENALTY")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    ForEach(viewModel.selectedPenalties, id: \.id) { penalty in
                                        HStack {
                                            Text(penalty.name)
                                                .font(.headline)
                                            Spacer()
                                            Text("-\(penalty.points) PTS")
                                                .font(.headline)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                    }
                }
                
// 6. Button Toolbar Component
struct ScoreButtonToolbar: View {
    @ObservedObject var viewModel: ScoreEntryViewModel
    @Binding var showLinesView: Bool
    @Binding var showTricksView: Bool
    @Binding var showECPsView: Bool
    @Binding var showPenaltiesView: Bool
    
    var body: some View {
                HStack(spacing: 16) {
            if viewModel.currentSession?.mountain.name != "Free Range" {
                        Button(action: { showLinesView = true }) {
                            VStack {
                                Image(systemName: "mountain.2")
                                    .foregroundColor(.blue)
                                Text("Line")
                            }
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("LineButton")
                    }
                    
                    Button(action: { showTricksView = true }) {
                        VStack {
                            Image(systemName: "figure.skiing.downhill")
                                .foregroundColor(.orange)
                            Text("Trick")
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("TrickButton")
                    
                    Button(action: { showECPsView = true }) {
                        VStack {
                            Image(systemName: "star")
                                .foregroundColor(.green)
                            Text("ECP")
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("ECPButton")
                    
                    Button(action: { showPenaltiesView = true }) {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            Text("Penalty")
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("PenaltyButton")
                }
                .padding()
            }
}

// Preview for development/testing
struct ScoreEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.preview.viewContext
        let appState = AppStateManager(coreDataStack: CoreDataStack.preview)
        let gameState = GameStateManager(viewContext: context, appState: appState)
        let viewModel = ScoreEntryViewModel(gameState: gameState)
        
        return ScoreEntryView(viewModel: viewModel)
    }
}

#if DEBUG
// Remove TestMultiSelectionView here
#endif




