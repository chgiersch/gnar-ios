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
    private let coreDataStack = CoreDataStack.shared

    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        _launchManager = StateObject(wrappedValue: LaunchStateManager(
            coreDataStack: CoreDataStack.shared,
            appState: appState
        ))
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                appState: appState,
                contentViewModel: contentViewModel
            )
            .environment(\.managedObjectContext, coreDataStack.viewContext)
            .environmentObject(appState)
            .environmentObject(launchManager)
            .task {
                await launchManager.beginLaunchSequence()
                await MainActor.run {
                    contentViewModel = ContentViewModel(coreDataStack: coreDataStack)
                }
            }
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
        let context = coreDataStack.viewContext
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
        let context = coreDataStack.viewContext
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

// Separate class to handle app-wide state
class AppState: ObservableObject {
    @Published var mountainSeedingComplete: Bool = false
    @Published var isReady = false
}
