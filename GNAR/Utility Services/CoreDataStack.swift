import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private let modelName: String
    let container: NSPersistentContainer
    
    // Main context - read operations, UI binding
    private(set) lazy var viewContext: NSManagedObjectContext = {
        let context = container.viewContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.automaticallyMergesChangesFromParent = true
        // Automatically refresh objects from changes in parent contexts
        // Deliver notifications on the main queue
        context.stalenessInterval = 0
        return context
    }()
    
    // Write context - used as parent for background operations
    private(set) lazy var writeContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    init(modelName: String = "GNAR", inMemory: Bool = false) {
        self.modelName = modelName
        container = NSPersistentContainer(name: modelName)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        setupContainer()
    }
    
    private func setupContainer() {
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("❌ CoreDataStack failed to load persistent store: \(error.localizedDescription)")
                print("Reason: \(error.localizedFailureReason ?? "Unknown")")
                print("Recovery suggestion: \(error.localizedRecoverySuggestion ?? "None")")
                
                // Only fatal in production, allows recovery in debug
                #if DEBUG
                print("WARNING: Core Data store failed to load but continuing in DEBUG mode")
                #else
                fatalError("Core Data store failed to load")
                #endif
            } else {
                print("✅ Core Data store loaded: \(description.url?.absoluteString ?? "Unknown")")
            }
        }
    }
    
    // Create a new background context for batch operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    // Create a task context as a child of the write context
    func newTaskContext() -> NSManagedObjectContext {
        let taskContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        taskContext.parent = writeContext
        taskContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        taskContext.automaticallyMergesChangesFromParent = true
        return taskContext
    }
    
    // Save a context and propagate changes up the chain
    func save(context: NSManagedObjectContext, completion: ((Error?) -> Void)? = nil) {
        // Don't save if there are no changes
        guard context.hasChanges else {
            completion?(nil)
            return
        }
        
        context.perform {
            do {
                try context.save()
                
                // If this is a child context, save the parent context as well
                if let parent = context.parent {
                    self.save(context: parent, completion: completion)
                } else {
                    completion?(nil)
                }
            } catch {
                print("❌ Error saving context: \(error.localizedDescription)")
                completion?(error)
            }
        }
    }
    
    // Perform a task on a background context
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            let context = newTaskContext()
            context.perform {
                do {
                    let result = try block(context)
                    
                    // Save this context if it has changes
                    if context.hasChanges {
                        try context.save()
                        
                        // Save the parent context
                        if let parent = context.parent {
                            self.save(context: parent) { error in
                                if let error = error {
                                    continuation.resume(throwing: error)
                                } else {
                                    continuation.resume(returning: result)
                                }
                            }
                        } else {
                            continuation.resume(returning: result)
                        }
                    } else {
                        continuation.resume(returning: result)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Testing Support
    
    static var preview: CoreDataStack = {
        let stack = CoreDataStack(inMemory: true)
        return stack
    }()
} 