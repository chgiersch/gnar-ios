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
        NavigationStack {
            Form {
                Section(header: Text("SELECT AREA")) {
                    ForEach(viewModel.mountains) { mountain in
                        MountainRow(
                            mountain: mountain,
                            isSelected: viewModel.selectedMountain?.id == mountain.id
                        ) {
                            viewModel.selectedMountain = mountain
                        }
                    }
                }

                Section(header: Text("PLAYERS")) {
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
            .navigationTitle("Start New Game")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        if let newSession = viewModel.createGameSession() {
                            onCreateSessionCallback(newSession)
                            dismiss()
                        }
                    }
                    .accessibilityIdentifier("Start")
                    .disabled(viewModel.playerNames.allSatisfy { $0.trimmingCharacters(in: .whitespaces).isEmpty })
                }
            }
            .onDisappear {
                NotificationCenter.default.post(name: .loadGameSessions, object: nil)
            }
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
        .accessibilityIdentifier("mountain-row-\(mountain.id)")
        .onTapGesture {
            onTap()
        }
    }
}
