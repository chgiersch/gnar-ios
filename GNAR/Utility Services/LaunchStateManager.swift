//
//  LaunchStateManager.swift
//  GNAR
//
//  Created by Chris Giersch on 4/8/25.
//

import Foundation
import SwiftUI
import CoreData

final class LaunchStateManager: ObservableObject {
    @Published var isReady: Bool = false
    @Published var loadingProgress: Float = 0.0
    @Published var loadingMessage: String = "Pole wacking..."

    private let coreData: CoreDataContexts
    private let appState: AppState

    init(coreData: CoreDataContexts, appState: AppState) {
        self.coreData = coreData
        self.appState = appState
    }

    @MainActor
    func beginLaunchSequence() async {
        // No more forced wait - loading will take as long as it actually needs
        loadingMessage = "Checking data..."
        loadingProgress = 0.1
        
        // Begin loading seed data
        if !UserDefaults.standard.hasSeededMountains {
            loadingMessage = "Loading mountains..."
            loadingProgress = 0.2
            await loadInitialSeedData()
        } else {
            loadingMessage = "Mountains already loaded"
            loadingProgress = 0.8
        }

        // Final loading steps
        loadingMessage = "Finalizing..."
        loadingProgress = 0.9
        
        // Small delay for UI smoothness
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        loadingProgress = 1.0
        appState.isReady = true
    }

    private func loadInitialSeedData() async {
        let totalMountains = 2 // Global and Squallywood
        var loadedCount = 0
        
        let context = coreData.backgroundContext
        
        // Load Global mountain
        let globalVersion = "v1.0"
        if SeedVersionManager.shared.shouldLoadSeed(for: "global", newVersion: globalVersion) {
            loadingMessage = "Loading Global mountain..."
            await loadMountain(named: "Global", context: context)
            SeedVersionManager.shared.markVersion(globalVersion, for: "global")
            
            loadedCount += 1
            await MainActor.run {
                loadingProgress = 0.2 + (0.6 * (Float(loadedCount) / Float(totalMountains)))
            }
        }
        
        // Load Squallywood mountain
        let squallywoodVersion = "v1.0"
        if SeedVersionManager.shared.shouldLoadSeed(for: "squallywood-mountain", newVersion: squallywoodVersion) {
            loadingMessage = "Loading Squallywood mountain..."
            await loadMountain(named: "SquallywoodMountain", context: context)
            SeedVersionManager.shared.markVersion(squallywoodVersion, for: "squallywood-mountain")
            
            loadedCount += 1
            await MainActor.run {
                loadingProgress = 0.2 + (0.6 * (Float(loadedCount) / Float(totalMountains)))
            }
        }
        
        await MainActor.run {
            UserDefaults.standard.hasSeededMountains = true
        }
    }
    
    private func loadMountain(named filename: String, context: NSManagedObjectContext) async {
        await withCheckedContinuation { continuation in
            Task {
                // Using Task to run this work on a background thread
                context.perform {
                    JSONLoader.loadMountain(named: filename, context: context)
                    continuation.resume()
                }
            }
        }
    }
}
