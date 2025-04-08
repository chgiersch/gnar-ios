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
    
    init(
        coreData: CoreDataContexts,
        mountains: [MountainPreview],
        onCreateSession: @escaping (GameSession) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: GameBuilderViewModel(
            coreData: coreData,
            mountains: mountains
        ))
        self.onCreateSessionCallback = onCreateSession
    }
    
    var body: some View {
        Form {
            Section {
                Text("Start a New GNAR Game")
                    .font(.title.bold())
            }

            Section(header: Text("Select Area")) {
                ForEach(viewModel.mountains) { mountain in
                    MountainRow(
                        mountain: mountain,
                        isSelected: viewModel.selectedMountain?.id == mountain.id
                    ) {
                        viewModel.selectedMountain = mountain
                    }
                }
            }

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
        .onDisappear {
            print("GameBuilderView disappeared.")
            NotificationCenter.default.post(name: .loadGameSessions, object: nil)
        }
    }
}

private struct MountainRow: View {
    let mountain: MountainPreview
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(mountain.name)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
