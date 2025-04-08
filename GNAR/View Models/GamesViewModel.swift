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
    private var hasLoaded = false

    var coreData: CoreDataContexts
    
    private let sessionFetcher: SessionFetching

    init(coreData: CoreDataContexts,
         sessionFetcher: SessionFetching = DefaultSessionFetcher()) {
        self.coreData = coreData
        self.sessionFetcher = sessionFetcher
    }
    
    @MainActor
    func loadIfNeeded() async {
        guard !hasLoaded, !isLoading else {
            print("🟡 Skipping load: already loading or data exists")
            return
        }
        
        print("🚀 Loading sessions...")
        await loadSessions()
        hasLoaded = true
    }

    @MainActor
    func loadSessions() async {
        self.isLoading = true
        do {
            let previews = try await sessionFetcher.fetchPreviews(context: coreData.backgroundContext)
            await MainActor.run {
                self.sessionPreviews = previews
                print("✅ Loaded \(previews.count) sessions from SessionFetcher.")
            }
        } catch {
            await MainActor.run {
                print("❌ Failed to fetch session previews: \(error)")
                self.sessionPreviews = []
            }
        }
        self.isLoading = false
    }

    func loadSession(by id: UUID) -> GameSession? {
        let request: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            return try coreData.viewContext.fetch(request).first
        } catch {
            print("❌ Failed to fetch session by ID: \(error)")
            return nil
        }
    }
}
