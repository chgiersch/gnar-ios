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
    @StateObject private var appStateManager: AppStateManager
    @StateObject private var gameStateManager: GameStateManager
    @StateObject private var launchStateManager: LaunchStateManager
    @StateObject private var contentViewModel: ContentViewModel
    
    private let coreDataStack = CoreDataStack.shared
    
    // MARK: - Initialization
    init() {
        // Create AppState instance first and configure with CoreDataStack
        let appStateInstance = AppStateManager(coreDataStack: CoreDataStack.shared)
        _appStateManager = StateObject(wrappedValue: appStateInstance)
        
        // Initialize GameStateManager with CoreData context
        let gameManager = GameStateManager(
            viewContext: coreDataStack.viewContext,
            appState: appStateInstance
        )
        _gameStateManager = StateObject(wrappedValue: gameManager)
        
        // Initialize ContentViewModel
        _contentViewModel = StateObject(wrappedValue: ContentViewModel(gameState: gameManager, appState: appStateInstance))
        
        // Use appStateInstance (not appState) for LaunchStateManager
        let launchManager = LaunchStateManager(
            coreDataStack: coreDataStack,
            appState: appStateInstance  // Use the instance, not the property
        )
        _launchStateManager = StateObject(wrappedValue: launchManager)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
            if appStateManager.isLoading {
                LoadingScreen()
            } else {
                    ContentView(viewModel: contentViewModel)
                }
            }
            .environmentObject(appStateManager)
            .environmentObject(gameStateManager)
            .environmentObject(launchStateManager)
        }
    }
    
    // Development/Debug functions
    #if DEBUG
    func resetDebugStateIfNeeded() async {
        if CommandLine.arguments.contains("--reset-data") {
            await deleteAllData()
            UserDefaults.standard.hasSeededMountains = false
        }
    }
    
    func deleteAllData() async {
        await deleteAllGameSessions()
        await deleteAllMountains()
    }
    
    func deleteAllMountains() async {
        let context = CoreDataStack.shared.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Mountain.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("✅ All mountains deleted")
        } catch {
            print("❌ Failed to delete mountains: \(error)")
        }
    }
    
    func deleteAllGameSessions() async {
        let context = CoreDataStack.shared.viewContext
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
    #endif
}

