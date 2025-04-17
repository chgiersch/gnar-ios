import Foundation
import CoreData

// MARK: - NSManagedObjectContext Extensions

extension NSManagedObjectContext {
    
    /// Perform a fetch request and return the results
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) async throws -> [T] {
        try await perform {
            try self.fetch(request)
        }
    }
    
    /// Perform a save operation asynchronously
    func saveAsync() async throws {
        try await perform {
            if self.hasChanges {
                try self.save()
            }
        }
    }
    
    /// Execute a block on this context asynchronously
    func performAsync<T>(_ block: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            perform {
                do {
                    let result = try block()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - CodingUserInfoKey Extension

extension CodingUserInfoKey {
    /// Context key for JSONDecoder with CoreData
    static let codingContext = CodingUserInfoKey(rawValue: "context")
}

// MARK: - MountainPreview Extension

extension MountainPreview {
    /// Initialize a mountain preview from a Mountain entity
    init(mountain: Mountain) {
        self.id = mountain.id
        self.name = mountain.name == "Global" ? "Free Range" : (mountain.name)
        self.isGlobal = mountain.isGlobal
    }
} 
