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
    @Published var selectedMountain: Mountain?
    @Published var globalMountain: Mountain?
    @Published var userMountains: [Mountain] = []
    @Published var playerNames: [String] = [""]
    @Published var createdGameSession: GameSession?

    var mountains: [Mountain] {
        var result = [Mountain]()
        if let global = globalMountain {
            result.append(global)
        }
        result.append(contentsOf: userMountains)
        return result
    }

    private let coreData: CoreDataContexts

    init(coreData: CoreDataContexts) {
        self.coreData = coreData
        Task {
            await fetchMountains()
        }
    }

    func fetchMountains() async {
        let request: NSFetchRequest<Mountain> = Mountain.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Mountain.name, ascending: true)]

        do {
            let fetched = try coreData.viewContext.fetch(request)
            print("🗻 Found \(mountains.count) mountains")

            await MainActor.run {
                if let global = fetched.first(where: { $0.name == "Global" }) {
                    global.name = "Free Range"
                    self.globalMountain = global
                }

                self.userMountains = fetched.filter { $0 != self.globalMountain }
            }
        } catch {
            print("❌ Failed to fetch mountains: \(error)")
        }
    }

    func createGameSession() -> GameSession? {
        guard let selectedMountain = selectedMountain, !playerNames.isEmpty else {
            return nil
        }

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
