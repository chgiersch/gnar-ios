//
//  GamesViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import SwiftUI
import CoreData

class GamesViewModel: ObservableObject {
    @Published var sessions: [GameSession] = []
    @Published var activeSession: GameSession?
    @Published var showingGameBuilder = false
    @Published var selectedMountain: Mountain?
    @Published var sessionPreviews: [GameSessionPreview] = []
    @Published var isLoading = false

    var viewContext: NSManagedObjectContext
    var backgroundContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.backgroundContext = backgroundContext

        // Automatically refresh when other contexts save
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: .main) { notification in
            self.viewContext.mergeChanges(fromContextDidSave: notification)
        }
        
        NotificationCenter.default.addObserver(forName: .loadGameSessions, object: nil, queue: .main) { _ in
            Task {
                await self.loadSessions()
            }
        }
    }

    func createNewGame(mountainName: String, players: [Player]) {
        let bgContext = backgroundContext

        bgContext.perform {
            guard let entity = NSEntityDescription.entity(forEntityName: "GameSession", in: bgContext) else {
                fatalError("Failed to find entity description for GameSession")
            }
            let newSession = GameSession(entity: entity, insertInto: bgContext)
            newSession.mountainName = mountainName
            newSession.startDate = Date()

            let playerEntities = players.map { inputPlayer -> Player in
                let player = Player(context: bgContext)
                player.id = inputPlayer.id ?? UUID()
                player.name = inputPlayer.name
                return player
            }
            newSession.players = NSSet(array: playerEntities)

            do {
                try bgContext.save()

                let viewContext = PersistenceController.shared.container.viewContext
                viewContext.perform {
//                    self.loadSessions()
                }
            } catch {
                bgContext.rollback()
                print("❌ Failed to save new game session in background: \(error)")
            }
        }
    }
    
    @MainActor
    func loadIfNeeded() async {
        guard sessionPreviews.isEmpty else { return }
        await loadSessions()
    }

    @MainActor
    func loadSessions() async {
        self.isLoading = true

        let request = NSFetchRequest<GameSession>(entityName: "GameSession")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]

        do {
            let results = try await viewContext.perform {
                try self.viewContext.fetch(request)
            }

            let previews = results.compactMap { session -> GameSessionPreview? in
                guard let id = session.id, let date = session.startDate else { return nil }
                return GameSessionPreview(id: id, mountainName: session.mountainName, date: date)
            }
            
            if previews.isEmpty {
                print("⚠️ No sessions found — consider creating a test session.")
            }

            self.sessionPreviews = previews
            print("✅ Set sessionPreviews: \(previews.count)")
            self.isLoading = false
        } catch {
            self.sessionPreviews = []
            self.isLoading = false
        }
    }
}

struct GameSessionPreview: Identifiable {
    let id: UUID
    let mountainName: String
    let date: Date
}
