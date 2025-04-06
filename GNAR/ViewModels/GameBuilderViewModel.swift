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

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchMountains()
    }

    func fetchMountains() {
        let request: NSFetchRequest<Mountain> = Mountain.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Mountain.name, ascending: true)]

        do {
            let fetched = try context.fetch(request)
            print("🗻 Found \(mountains.count) mountains")

            if let global = fetched.first(where: { $0.name == "Global" }) {
                global.name = "Free Range"
                self.globalMountain = global
            }

            self.userMountains = fetched.filter { $0 != self.globalMountain }

        } catch {
            print("❌ Failed to fetch mountains: \(error)")
        }
    }

    func addPlayer() {
        playerNames.append("")
    }

    func removePlayer(at index: Int) {
        playerNames.remove(at: index)
    }

    func createGameSession() -> GameSession? {
        guard let selectedMountain = selectedMountain, !playerNames.isEmpty else {
            return nil
        }

        let gameSession = GameSession(context: context)
        gameSession.mountainName = selectedMountain.name
        gameSession.id = UUID()
        gameSession.startDate = Date()

        let players = playerNames.map { name -> Player in
            let player = Player(context: context)
            player.name = name
            return player
        }

        gameSession.players = NSSet(array: players)

        do {
            try context.save()
            self.createdGameSession = gameSession
            return gameSession
        } catch {
            context.rollback()
            print("❌ Failed to save game session: \(error)")
            return nil
        }
    }
}
