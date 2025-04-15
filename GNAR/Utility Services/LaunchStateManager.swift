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

    private let coreDataStack: CoreDataStack
    private let appState: AppState

    init(coreDataStack: CoreDataStack = CoreDataStack.shared, appState: AppState) {
        self.coreDataStack = coreDataStack
        self.appState = appState
    }

    @MainActor
    func beginLaunchSequence() async {
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

    @MainActor
    private func loadInitialSeedData() async {
        do {
            // Define which mountains to load
            let mountainFiles = ["Global", "SquallywoodMountain"]
            
            // Load mountains with progress updates
            for (index, filename) in mountainFiles.enumerated() {
                let progress = Float(index) / Float(mountainFiles.count)
                self.loadingProgress = 0.2 + (0.6 * progress)
                self.loadingMessage = "Loading mountains... \(Int(progress * 100))%"
                
                // Use the main view context for all operations
                JSONLoader.loadMountain(named: filename, context: coreDataStack.viewContext)
                
                // Save changes
                try coreDataStack.viewContext.save()
            }
            
            UserDefaults.standard.hasSeededMountains = true
        } catch {
            print("❌ Error loading mountains: \(error.localizedDescription)")
            // Even with an error, we'll continue and let the app launch
            self.loadingMessage = "Error loading some data"
        }
    }
}
