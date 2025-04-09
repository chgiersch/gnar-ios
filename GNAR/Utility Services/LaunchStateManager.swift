//
//  LaunchStateManager.swift
//  GNAR
//
//  Created by Chris Giersch on 4/8/25.
//


import Foundation

final class LaunchStateManager: ObservableObject {
    @Published var isReady: Bool = false

    private let coreData: CoreDataContexts
    private let appState: AppState

    init(coreData: CoreDataContexts, appState: AppState) {
        self.coreData = coreData
        self.appState = appState
    }

    @MainActor
    func beginLaunchSequence() async {
        // Show loading screen for at least 4 seconds
        let minWait = Task { try? await Task.sleep(nanoseconds: 4_000_000_000) }

        // Begin loading seed data
        if !UserDefaults.standard.hasSeededMountains {
            await loadInitialSeedData()
        }

        _ = await minWait.result // wait 4 sec total, even if loading was fast

        appState.isReady = true
    }

    private func loadInitialSeedData() async {
        let context = coreData.backgroundContext
        await context.perform {
            // Seeding logic as in `loadInitialSeedData()` from `GNARApp.swift`
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
            UserDefaults.standard.hasSeededMountains = true
        }
    }
}
