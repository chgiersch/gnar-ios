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
    
    init(viewContext: NSManagedObjectContext, onGameCreated: ((GameSession) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: GameBuilderViewModel(viewContext: viewContext))
        self.onGameCreated = onGameCreated
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Mountain Selection Section
                Section("SELECT AREA") {
                    ForEach(["Free Range", "Squallywood"], id: \.self) { mountain in
                        Button {
                            viewModel.selectedMountain = mountain
                        } label: {
                            HStack {
                                Text(mountain)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.selectedMountain == mountain {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                // Player Entry Section
                Section {
                    ForEach(0..<viewModel.playerNames.count, id: \.self) { index in
                        TextField("Player \(index + 1)", text: $viewModel.playerNames[index])
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                            .focused($focusedField, equals: index)
                            .accessibilityIdentifier("Player \(index + 1)")
                    }
                    
                    Button("Add Player") {
                        viewModel.addPlayerField()
                        focusedField = viewModel.playerNames.count - 1
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.playerNames.count >= 10)
                }
                
                // Start Game Section
                Section {
                    Button("Start") {
                        Task {
                            do {
                                print("Starting game creation process...")
                                let gameSession = try await viewModel.startGame()
                                print("Game created successfully, dismissing view...")
                                onGameCreated?(gameSession)
                                dismiss()
                            } catch {
                                print("Error creating game: \(error)")
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!viewModel.canStartGame)
                }
            }
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    GameBuilderView(viewContext: CoreDataStack.preview.viewContext)
}

