//
//  ScoreEntryView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/31/25.
//


import SwiftUI
import CoreData

struct ScoreEntryView: View {
    // MARK: - Properties
    
    let selectedPlayer: Player
    let gameSession: GameSession
    let onDismiss: () -> Void
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ScoreEntryViewModel
    
    // MARK: - UI State
    @State private var showLinesView = false
    @State private var showTricksView = false
    @State private var showECPsView = false
    @State private var showPenaltiesView = false
    
    // Simply define FetchRequests directly - they'll get context from environment
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \LineWorth.name, ascending: true)])
    private var lines: FetchedResults<LineWorth>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TrickBonus.name, ascending: true)])
    private var tricks: FetchedResults<TrickBonus>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ECP.name, ascending: true)])
    private var ecps: FetchedResults<ECP>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Penalty.name, ascending: true)])
    private var penalties: FetchedResults<Penalty>
    
    // MARK: - Initialization
    
    init(viewContext: NSManagedObjectContext,
         selectedPlayer: Player,
         gameSession: GameSession, onDismiss: @escaping () -> Void) {
        self.selectedPlayer = selectedPlayer
        self.gameSession = gameSession
        self.onDismiss = onDismiss
        _viewModel = StateObject(wrappedValue: ScoreEntryViewModel(
            viewContext: viewContext,
            selectedPlayer: selectedPlayer,
            gameSession: gameSession
        ))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack {
                // Player Header
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("PLAYER")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(selectedPlayer.name)
                                .font(.headline)
                        }
                        Spacer()
                        if viewModel.hasSelectedLine {
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
                
                // Score Sections
                ScrollView {
                    VStack(spacing: 16) {
                        // Line Section - Only show if not Free Range
                        if gameSession.mountainName != "Free Range" {
                            if viewModel.hasSelectedLine {
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
                        
                        // Trick Section
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
                        
                        // ECP Section
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
                        
                        // Penalty Section
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
                    .padding()
                }
                
                // Bottom Buttons
                HStack(spacing: 16) {
                    if gameSession.mountainName != "Free Range" {
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
            .navigationTitle("Score Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .accessibilityIdentifier("CancelScoreButton")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.canAddScore {
                        Button("Add") {
                            Task {
                                do {
                                    try await viewModel.saveCurrentScore()
                                    onDismiss()
                                } catch {
                                    print("Failed to save score: \(error)")
                                    // TODO: Show error to user
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
                    allTrickBonuses: Array(tricks),
                    selectedBonuses: $viewModel.selectedTricks
                )
            }
            .sheet(isPresented: $showECPsView) {
                ECPPickerView(
                    allECPs: Array(ecps),
                    selectedECPs: $viewModel.selectedECPs
                )
            }
            .sheet(isPresented: $showPenaltiesView) {
                PenaltyPickerView(
                    allPenalties: Array(penalties),
                    selectedPenalties: $viewModel.selectedPenalties
                )
            }
        }
        .environment(\.managedObjectContext, viewModel.viewContext)
    }
}

#if DEBUG
// Remove TestMultiSelectionView here
#endif




