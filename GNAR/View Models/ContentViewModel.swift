//
//  ContentViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import SwiftUI
import CoreData

@MainActor
class ContentViewModel: ObservableObject {
    @Published var mountainPreviews: [MountainPreview] = [] {
        didSet { print("📥 mountainPreviews updated at", Date()) }
    }
    @Published var globalMountainPreview: MountainPreview? {
        didSet { print("📥 globalMountainPreview updated at", Date()) }
    }
    @Published var activeSession: GameSession? = nil {
        didSet { print("📥 activeSession updated at", Date()) }
    }
    @Published var showingGameBuilder: Bool = false {
        didSet { print("📥 showingGameBuilder updated at", Date()) }
    }
    @Published var sessionPreviews: [GameSessionPreview]? = nil {
        didSet { print("📥 sessionPreviews updated at", Date()) }
    }
    @Published var visibleSessions: [GameSessionPreview]? = nil {
        didSet { print("📥 visibleSessions updated at", Date()) }
    }
    @Published var visibleCount: Int = 10 {
        didSet { print("📥 visibleCount updated at", Date()) }
    }
    @Published var isLoadingSessions: Bool = false {
        didSet { print("📥 isLoadingSessions updated at", Date()) }
    }
    private var hasLoadedSessions = false {
        didSet { print("📥 hasLoadedSessions updated at", Date()) }
    }

    // Core data stack
    let coreDataStack: CoreDataStack
    
    // State
    @Published var selectedTab: Tab = .home {
        didSet {
            if selectedTab == .home {
                Task {
                    await loadMountains()
                }
            }
        }
    }
    
    // Data
    @Published var mountains: [Mountain] = []
    @Published var selectedSession: GameSession?
    @Published var isLoading = false
    @Published var error: Error?
    
    enum Tab: Hashable {
        case home, games, profile
    }

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        Task {
            await loadMountains()
        }
    }
    
    // MARK: - Mountain Management
    
    func loadMountains() async {
        do {
            let request = Mountain.fetchRequest()
            mountains = try await coreDataStack.viewContext.fetch(request)
            await MainActor.run {
                self.mountainPreviews = mountains.map { mountain in
                    return MountainPreview(mountain: mountain)
                }
                
                // Set global mountain
                self.globalMountainPreview = mountains
                    .first(where: { $0.isGlobal })
                    .map { MountainPreview(mountain: $0) }
            }
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Session Management
    
    func loadSessionPreviews() async {
        do {
            let request = GameSession.fetchRequest()
            let sessions = try await coreDataStack.viewContext.fetch(request)
            sessionPreviews = sessions.map { GameSessionPreview(from: $0) }
        } catch {
            self.error = error
        }
    }
    
    func loadSession(id: UUID) async {
        do {
            let request = GameSession.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            let sessions = try await coreDataStack.viewContext.fetch(request)
            selectedSession = sessions.first
        } catch {
            self.error = error
        }
    }
    
    func addScore(_ score: Score, to session: GameSession) async throws {
        session.addToScores(score)
        try await coreDataStack.viewContext.save()
    }
    
    func createSession(mountainName: String, players: [Player]) async throws -> GameSession {
        let session = GameSession(context: coreDataStack.viewContext)
        session.id = UUID()
        session.mountainName = mountainName
        session.startDate = Date()
        
        // Add players to the game session
        for player in players {
            session.addToPlayers(player)
        }
        
        try await coreDataStack.viewContext.save()
        return session
    }
    
    // MARK: - Sessions
    
    func loadSessionsIfNeeded() async {
        if !hasLoadedSessions || sessionPreviews == nil || sessionPreviews?.isEmpty == true {
            await loadInitialSessions()
        }
        hasLoadedSessions = true
        isLoadingSessions = false
    }
    
    func loadInitialSessions() async {
        print("📱 Starting to load initial sessions...")
        isLoadingSessions = true
        do {
            let request = GameSession.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \GameSession.startDate, ascending: false)]
            request.fetchLimit = 20
            let sessions = try await coreDataStack.viewContext.fetch(request)
            
            print("📱 Found \(sessions.count) sessions in Core Data")
            sessionPreviews = sessions.map { session in
                let preview = GameSessionPreview(from: session)
                print("📱 Created preview for session: \(session.id.uuidString)")
                print("📱 - Mountain: \(preview.mountainName)")
                print("📱 - Players: \(preview.playerCount)")
                print("📱 - Date: \(preview.startDate)")
                return preview
            }
            updateVisibleSessions()
            print("📱 Updated visible sessions count: \(visibleSessions?.count ?? 0)")
        } catch {
            print("📱 Error loading sessions: \(error)")
            self.error = error
            isLoadingSessions = false
        }
    }
    
    func loadMoreSessions() {
        updateVisibleSessions(count: visibleCount + 10)
    }
    
    func updateVisibleSessions(count: Int? = nil) {
        if let count = count {
            visibleCount = count
        }
        
        if let allSessions = sessionPreviews {
            visibleSessions = Array(allSessions.prefix(visibleCount))
            print("📱 Updated visible sessions:")
            visibleSessions?.forEach { session in
                print("📱 - Session: \(session.mountainName)")
                print("📱   Players: \(session.playerCount)")
                print("📱   Date: \(session.startDate)")
            }
        }
    }
}

extension NSNotification.Name {
    static let loadGameSessions = NSNotification.Name("loadGameSessions")
}
