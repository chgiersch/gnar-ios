//
//  ContentViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import SwiftUI
import CoreData

class ContentViewModel: ObservableObject {
//    @Published var globalMountain: Mountain?
//    @Published var mountains: [Mountain] = []
    @Published var mountainPreviews: [MountainPreview] = []
    @Published var globalMountainPreview: MountainPreview?
    @Published var activeSession: GameSession? = nil
    let gamesViewModel: GamesViewModel

    let viewContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    
    @Published var selectedTab: Tab = .home {
        didSet {
            if ![.home, .games, .profile].contains(selectedTab) {
                print("❗ Invalid tab selected. Reverting to .home")
                selectedTab = .home
            }
        }
    }
    
    init(coreData: CoreDataContexts) {
        self.viewContext = coreData.viewContext
        self.backgroundContext = coreData.backgroundContext
        
        self.gamesViewModel = GamesViewModel(
            coreData: coreData,
            sessionFetcher: DefaultSessionFetcher()
        )
        
        Task {
            print("🚀 Preloading session previews from ContentViewModel")
            await self.gamesViewModel.loadIfNeeded()
        }
        Task {
            print("🏔️ Preloading mountains from ContentViewModel")
            await loadMountains()
        }
    }
    
    enum Tab: Hashable {
        case home, games, profile
    }
    
    func loadMountains() async {
        let request: NSFetchRequest<Mountain> = Mountain.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Mountain.name, ascending: true)]

        do {
            let fetched = try viewContext.fetch(request)
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

                // Separate & sort with global mountain first
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

    func loadSession(by id: UUID) {
        let request: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let session = try viewContext.fetch(request).first {
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
