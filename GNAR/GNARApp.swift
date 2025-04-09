//
//  GNARApp.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//

import SwiftUI
import CoreData

@main
struct GNARApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var launchManager: LaunchStateManager
    @State private var contentViewModel: ContentViewModel?
    private let persistenceController = PersistenceController.shared

    var coreData: CoreDataContexts {
        CoreDataContexts(
            viewContext: persistenceController.container.viewContext,
            backgroundContext: persistenceController.container.newBackgroundContext()
        )
    }
    
    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        _launchManager = StateObject(wrappedValue: LaunchStateManager(coreData: CoreDataContexts(
            viewContext: PersistenceController.shared.container.viewContext,
            backgroundContext: PersistenceController.shared.container.newBackgroundContext()
        ), appState: appState))
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                appState: appState,
                contentViewModel: contentViewModel
            )
            .environment(\.managedObjectContext, coreData.viewContext)
            .environmentObject(appState)
            .task {
                await launchManager.beginLaunchSequence()
                await MainActor.run {
                    contentViewModel = ContentViewModel(coreData: coreData)
                }
            }
        }
    }
    
//#if DEBUG
//                await resetDebugStateIfNeeded()
//#endif
    
    // MARK: - Debug Reset
    func resetDebugStateIfNeeded() async {
        await MainActor.run {
            SeedVersionManager.shared.resetAllVersions()
        }
        await deleteAllMountains()
        await deleteAllGameSessions()
    }

    // MARK: - Data Seeding
    func loadInitialSeedData() async {
        print("🚀 Starting initial seed data load.")
        if UserDefaults.standard.hasSeededMountains {
            await MainActor.run {
                self.contentViewModel = ContentViewModel(coreData: coreData)
                appState.mountainSeedingComplete = true
                appState.isReady = true
                print("✅ Mountains already seeded. App is ready.")
            }
            return
        }

        let context = coreData.backgroundContext
        await context.perform {
            let globalVersion = "v1.0"
            let squallywoodVersion = "v1.0"

            if SeedVersionManager.shared.shouldLoadSeed(for: "global", newVersion: globalVersion) {
                JSONLoader.loadMountain(named: "Global", context: context)
                SeedVersionManager.shared.markVersion(globalVersion, for: "global")
            }

            if SeedVersionManager.shared.shouldLoadSeed(for: "squallywood-mountain", newVersion: squallywoodVersion) {
                JSONLoader.loadMountain(named: "SquallywoodMountain", context: context)
                SeedVersionManager.shared.markVersion(squallywoodVersion, for: "squallywood-mountain")
            }
        }

        await MainActor.run {
            self.contentViewModel = ContentViewModel(coreData: coreData)
            appState.mountainSeedingComplete = true
            appState.isReady = true
            UserDefaults.standard.hasSeededMountains = true
            print("✅ Initial seed data loaded. App is ready.")
        }
    }

    func deleteAllMountains() async {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Mountain.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("🗑 All mountains deleted")
        } catch {
            print("❌ Failed to delete mountains: \(error)")
        }
    }
    
    func deleteAllGameSessions() async {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = GameSession.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("🗑 All game sessions deleted")
        } catch {
            print("❌ Failed to delete game sessions: \(error)")
        }
    }
}

// Separate class to handle app-wide state
class AppState: ObservableObject {
    @Published var mountainSeedingComplete: Bool = false
    @Published var isReady = false
}
