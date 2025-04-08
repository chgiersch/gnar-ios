//
//  GameBuilderViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//


import Foundation
import SwiftUI
import CoreData

class GameBuilderViewModel: ObservableObject {
    @Published var mountains: [MountainPreview] = []
    @Published var selectedMountain: MountainPreview?
    @Published var playerNames: [String] = [""]
    @Published var createdGameSession: GameSession?

    private let coreData: CoreDataContexts

    init(coreData: CoreDataContexts, mountains: [MountainPreview]) {
        self.coreData = coreData
        self.mountains = mountains
        self.selectedMountain = mountains.first // assumes global is first
    }
    
    func addPlayer() {
        playerNames.append("")
    }
    
    func removePlayer(at index: Int) {
        guard playerNames.indices.contains(index) else { return }
        playerNames.remove(at: index)
    }

    func createGameSession() -> GameSession? {
        
        guard let selectedMountain = selectedMountain, !playerNames.isEmpty else {
            return nil
        }
        print("🎯 Attempting to create session for mountain: \(selectedMountain.name)")
        print("👥 Player names: \(playerNames)")

        let gameSession = GameSession(context: coreData.viewContext)
        gameSession.mountainName = selectedMountain.name
        gameSession.id = UUID()
        gameSession.startDate = Date()

        let players = playerNames.map { name -> Player in
            let player = Player(context: coreData.viewContext)
            player.id = UUID()
            player.name = name
            return player
        }

        gameSession.players = NSSet(array: players)

        do {
            try coreData.viewContext.save()
            self.createdGameSession = gameSession
            return gameSession
        } catch {
            coreData.viewContext.rollback()
            print("❌ Failed to save game session: \(error)")
            return nil
        }
    }

    func bindingForPlayer(at index: Int) -> Binding<String> {
        Binding(
            get: {
                guard self.playerNames.indices.contains(index) else { return "" }
                return self.playerNames[index]
            },
            set: { newValue in
                guard self.playerNames.indices.contains(index) else { return }
                self.playerNames[index] = newValue
            }
        )
    }
}
