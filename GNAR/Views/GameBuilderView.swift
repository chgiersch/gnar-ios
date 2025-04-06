//
//  GameBuilderView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/31/25.
//

import SwiftUI
import CoreData

struct GameBuilderView: View {
    @StateObject private var viewModel: GameBuilderViewModel
    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusedPlayerIndex: Int?
    
    let onCreateSessionCallback: (GameSession) -> Void
    
    // Initialize the view model with the provided context and callback
    init(context: NSManagedObjectContext, onCreateSession: @escaping (GameSession) -> Void) {
        _viewModel = StateObject(wrappedValue: GameBuilderViewModel(context: context))
        self.onCreateSessionCallback = onCreateSession
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Section for selecting the mountain area
                Section(header: Text("Select Area")) {
                    List(viewModel.mountains, id: \.id) { mountain in
                        HStack {
                            Text(mountain.name)
                            Spacer()
                            if viewModel.selectedMountain == mountain {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedMountain = mountain
                        }
                    }
                }

                // Section for adding and removing players
                Section(header: Text("Players")) {
                    ForEach(Array(viewModel.playerNames.enumerated()), id: \.offset) { index, _ in
                        HStack {
                            TextField("You", text: $viewModel.playerNames[index])
                                .focused($focusedPlayerIndex, equals: index)
                                .submitLabel(.next)

                            if viewModel.playerNames.count > 1 {
                                Button(action: {
                                    viewModel.removePlayer(at: index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    Button(action: {
                        viewModel.addPlayer()
                        focusedPlayerIndex = viewModel.playerNames.count - 1
                    }) {
                        Label("Add Player", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        print("Attempting to create game session...")
                        if let newSession = viewModel.createGameSession() {
                            
                            
                            print("✅ Game session created successfully for mountain: \(newSession.mountainName)")
                            if let players = newSession.players as? Set<Player> {
                                print("👥 Players: \(players.map { $0.name })")
                            }
                            
                            
                            viewModel.createdGameSession = newSession
                            onCreateSessionCallback(newSession)
                            dismiss()
                        } else {
                            print("Failed to create game session.")
                        }
                    }
                    .disabled(viewModel.playerNames.allSatisfy { $0.trimmingCharacters(in: .whitespaces).isEmpty })
                }
            }
            .onAppear {
                print("GameBuilderView appeared.")
                if let freeRangeMountain = viewModel.mountains.first(where: { $0.name == "Free Range" }) {
                    viewModel.selectedMountain = freeRangeMountain
                }
            }
            .onDisappear {
                print("GameBuilderView disappeared.")
                NotificationCenter.default.post(name: .loadGameSessions, object: nil)
            }
        }
    }
}
