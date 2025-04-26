//
//  GameBuilderView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/31/25.
//

import SwiftUI
import CoreData

struct GameBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GameBuilderViewModel
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Int?
    var onGameCreated: ((GameSession) -> Void)?
    
    init(viewContext: NSManagedObjectContext, gameState: GameState, onGameCreated: ((GameSession) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: GameBuilderViewModel(viewContext: viewContext, gameState: gameState))
        self.onGameCreated = onGameCreated
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Toolbar
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .accessibilityIdentifier("CancelButton")
                
                Spacer()
                
                Text("New Game")
                    .font(.headline)
                
                Spacer()
                
                Button("Start") {
                    Task {
                        do {
                            let gameSession = try await viewModel.startGame()
                            onGameCreated?(gameSession)
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                            showingError = true
                        }
                    }
                }
                .disabled(!viewModel.canStartGame)
                .accessibilityIdentifier("StartGameButton")
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.separator)),
                alignment: .bottom
            )
            
            // Form Content
            Form {
                // Mountain Selection Section
                Section("SELECT AREA") {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        ForEach(viewModel.availableMountains, id: \.id) { mountain in
                            Button {
                                viewModel.selectedMountain = mountain
                            } label: {
                                HStack {
                                    Text(mountain.name ?? "")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if viewModel.selectedMountain?.id == mountain.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .accessibilityIdentifier("mountain-\(mountain.name ?? "")")
                        }
                    }
                }
                
                // Player Entry Section
                Section {
                    VStack(spacing: 12) {
                        ForEach(0..<viewModel.playerNames.count, id: \.self) { index in
                            TextField("Player \(index + 1)", text: $viewModel.playerNames[index])
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                                .focused($focusedField, equals: index)
                                .frame(maxWidth: .infinity)
                                .accessibilityIdentifier("Player \(index + 1)")
                        }
                        
                        Button("Add Player") {
                            viewModel.addPlayerField()
                            focusedField = viewModel.playerNames.count - 1
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.playerNames.count >= 10)
                        .accessibilityIdentifier("AddPlayerButton")
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await viewModel.loadMountains()
        }
    }
}

#Preview {
    let coreDataStack = CoreDataStack.preview
    let appState = AppStateManager(coreDataStack: coreDataStack)
    let gameState = GameStateManager(viewContext: coreDataStack.viewContext, appState: appState)
    
    return GameBuilderView(
        viewContext: coreDataStack.viewContext,
        gameState: gameState
    )
    .environmentObject(appState)
}

