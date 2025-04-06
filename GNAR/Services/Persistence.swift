//
//  Persistence.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//

import CoreData

final class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    lazy var backgroundContext: NSManagedObjectContext = {
        var context = container.newBackgroundContext()
        return context
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GNAR")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("❌ Unable to load persistent store: \(error.localizedDescription)\nReason: \(error.localizedFailureReason ?? "Unknown")\nSuggestion: \(error.localizedRecoverySuggestion ?? "None")")
            } else {
                print("✅ Core Data store loaded: \(description.url?.absoluteString ?? "Unknown")")
            }
        }

        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
}
