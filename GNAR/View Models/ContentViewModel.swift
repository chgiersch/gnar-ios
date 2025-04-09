//
//  ContentViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import SwiftUI
import CoreData

class ContentViewModel: ObservableObject {
    @Published var mountainPreviews: [MountainPreview] = [] {
        didSet { print("📥 mountainPreviews updated at", Date()) }
    }
    @Published var globalMountainPreview: MountainPreview? {
        didSet { print("📥 globalMounatinPreviews updated at", Date()) }
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

    let coreData: CoreDataContexts
    
    @Published var selectedTab: Tab = .home {
        didSet {
            if ![.home, .games, .profile].contains(selectedTab) {
                print("❗ Invalid tab selected. Reverting to .home")
                selectedTab = .home
            }
        }
    }
    
    enum Tab: Hashable {
        case home, games, profile
    }

    init(coreData: CoreDataContexts) {
        self.coreData = coreData

        Task {
            print("🏔️ Preloading mountains from ContentViewModel")
            await loadMountains()
        }
    }
    
    func loadMountains() async {
        let request: NSFetchRequest<Mountain> = Mountain.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Mountain.name, ascending: true)]

        do {
            let fetched = try coreData.viewContext.fetch(request)
            await MainActor.run {
                var previews: [MountainPreview] = []

                for mountain in fetched {
                    let preview = MountainPreview(
                        id: mountain.id,
                        name: mountain.name == "Global" ? "Free Range" : mountain.name,
                        isGlobal: mountain.isGlobal
                    )
                    previews.append(preview)
                }

                if let global = previews.first(where: { $0.isGlobal }) {
                    self.globalMountainPreview = global
                    self.mountainPreviews = [global] + previews.filter { !$0.isGlobal }
                } else {
                    self.globalMountainPreview = nil
                    self.mountainPreviews = previews
                }

                print("🗻 Loaded \(self.mountainPreviews.count) mountains (global first if present)")
            }
        } catch {
            print("❌ Failed to fetch mountains: \(error)")
        }
    }

    func loadSessionsIfNeeded() async {
        guard !hasLoadedSessions else { return }
        hasLoadedSessions = true
        await loadInitialSessions()
    }

    func loadInitialSessions() async {
        await MainActor.run { self.isLoadingSessions = true }

        let request = NSFetchRequest<GameSession>(entityName: "GameSession")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        request.fetchLimit = 20
//        request.relationshipKeyPathsForPrefetching = ["players"]
        request.returnsObjectsAsFaults = false

        do {
            let start = Date()
            print("📡 Started loading sessions at", start)
            let sessions = try await coreData.viewContext.perform {
                try self.coreData.viewContext.fetch(request)
            }
            let end = Date()
            print("✅ Finished loading sessions at", end)
            print("⏱ Session load took \(end.timeIntervalSince(start))s")

            let previews = sessions.compactMap { GameSessionPreview(from: $0) }

            await MainActor.run {
                self.sessionPreviews = previews
                self.visibleSessions = Array(previews.prefix(visibleCount))
                self.isLoadingSessions = false
            }

            print("✅ Previews loaded: \(previews.count)")
        } catch {
            await MainActor.run { self.isLoadingSessions = false }
            print("❌ Failed to fetch session previews: \(error)")
        }
    }
    
    func loadMoreSessions() {
        guard let previews = sessionPreviews else { return }
        visibleCount += 10
        visibleSessions = Array(previews.prefix(visibleCount))
    }

    func loadSession(by id: UUID) {
        let request: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let session = try coreData.viewContext.fetch(request).first {
                print("🎯 Loaded session \(id)")
                activeSession = session
            } else {
                print("⚠️ No session found for ID \(id)")
            }
        } catch {
            print("❌ Failed to fetch session: \(error)")
        }
    }
}

extension NSNotification.Name {
    static let loadGameSessions = NSNotification.Name("loadGameSessions")
}
