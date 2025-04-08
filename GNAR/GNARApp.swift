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
    private let persistenceController = PersistenceController.shared
    var coreData: CoreDataContexts {
        CoreDataContexts(
            viewContext: persistenceController.container.viewContext,
            backgroundContext: persistenceController.container.newBackgroundContext()
        )
    }
    @StateObject private var appState = AppState()
    @State private var contentViewModel: ContentViewModel?

    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isReady, let viewModel = contentViewModel {
                    ContentView(viewModel: viewModel)
                        .transition(.opacity)
                        .environment(\.managedObjectContext, coreData.viewContext)
                        .environmentObject(appState)
                        .environmentObject(viewModel)
                } else {
                    LoadingScreen()
                        .transition(.opacity)
                }
            }
            .task {
//#if DEBUG
//                await resetDebugStateIfNeeded()
//#endif
                print("🟢 GNARApp started. Checking if mountains are seeded.")
                if UserDefaults.standard.hasSeededMountains {
                    await MainActor.run {
                        self.contentViewModel = ContentViewModel(coreData: coreData)
                        appState.isReady = true
                        print("✅ Mountains already seeded. App is ready.")
                    }
                } else {
                    await loadInitialSeedData()
                }
            }
            .animation(.easeInOut(duration: 0.4), value: appState.isReady)
        }
    }
    
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
