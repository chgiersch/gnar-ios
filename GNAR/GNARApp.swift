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
    // Make persistenceController private since it's only used internally
    private let persistenceController = PersistenceController.shared
    
    // Add @StateObject to handle app state
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewContext: persistenceController.container.viewContext, backgroundContext: persistenceController.container.newBackgroundContext())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .task {
#if DEBUG
                    SeedVersionManager.shared.resetAllVersions()
                    deleteAllMountains(context: persistenceController.container.viewContext) {
                        print("✅ Callback: Finished deleting all mountains.")
                    }
#endif
                    
                    seedDataLoader() // Load initial data if needed
                }
        }
    }
    
    func deleteAllMountains(context: NSManagedObjectContext, completion: (() -> Void)? = nil) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Mountain")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("🗑️ Deleted all Mountains.")
            completion?() // ✅ Call the completion handler
        } catch {
            print("❌ Failed to delete mountains: \(error)")
        }
    }

}

// Separate class to handle app-wide state
class AppState: ObservableObject {
    // Add app-wide state properties here
}

// Move appearance configuration to an extension
extension GNARApp {
    func configureAppearance() {
        // Set up any UIKit appearance proxies
    }
    
    func seedDataLoader() {
        let context = persistenceController.container.viewContext
        
        let globalVersion = "v1.0"
        let squallywoodVersion = "v1.0"
        
        if SeedVersionManager.shared.shouldLoadSeed(for: "global", newVersion: globalVersion) {
            JSONLoader.loadMountain(named: "Global", context: context)
        }
        
        if SeedVersionManager.shared.shouldLoadSeed(for: "squallywood-mountain", newVersion: squallywoodVersion) {
            JSONLoader.loadMountain(named: "SquallywoodMountain", context: context)
        }
    }
    
    // DEBUG ONLY: Function to reset all mountains for testing purposes
    func deleteAllMountains(context: NSManagedObjectContext) {
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

}
