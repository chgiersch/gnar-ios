//
//  AppStateManager.swift
//  GNAR
//
//  Created by Chris Giersch on 5/4/25.
//

import Foundation
import CoreData
import SwiftUI
import Combine

/// Manages global application state
@MainActor
final class AppStateManager: ObservableObject, AppState {
    // MARK: - Core Properties
    @Published var isLoading = true
    @Published var mountainSeedingComplete: Bool = false
    @Published private(set) var isLoadingSessions: Bool = false
    @Published private(set) var sessions: [GameSession] = []
    @Published var error: Error?
    
    private var coreDataStack: CoreDataStack?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var viewContext: NSManagedObjectContext? {
        coreDataStack?.viewContext
    }
    
    /// Sessions that haven't been deleted
    var visibleSessions: [GameSession] {
        sessions.filter { !$0.isDeleted }
    }
    
    // MARK: - Initialization
    
    init(coreDataStack: CoreDataStack? = nil) {
        self.coreDataStack = coreDataStack
        
        // Set up observers for game session changes
        NotificationCenter.default.publisher(for: .loadGameSessions)
            .sink { [weak self] _ in
                Task {
                    try? await self?.loadSessions()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup
    
    /// Configure the app state with a Core Data stack
    func configure(with coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Sessions Management
    
    /// Load sessions if needed, or refresh in background if already loaded
    func loadSessionsIfNeeded() async throws {
        // Return immediately if we have sessions
        if !sessions.isEmpty {
            // Refresh in background without blocking caller
            Task {
                try? await loadSessions()
            }
            return
        }
        
        // No sessions yet, load them
        try await loadSessions()
    }
    
    /// Load all game sessions from Core Data
    func loadSessions() async throws {
        guard let viewContext = viewContext else {
            throw AppStateError.coreDataNotInitialized
        }
        
        // Don't set loading flag if we already have data
        let wasEmpty = sessions.isEmpty
        if wasEmpty {
            isLoadingSessions = true
        }
        defer { isLoadingSessions = false }
        
        do {
            let request = GameSession.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \GameSession.startDate, ascending: false)]
            
            // Use a background context for fetch to avoid blocking the UI
            let backgroundContext = viewContext.parent ?? viewContext
            let backgroundSessions = try await backgroundContext.perform {
                return try backgroundContext.fetch(request)
            }
            
            // Convert to main context objects if needed
            if backgroundContext != viewContext {
                // Convert IDs to main context
                let ids = backgroundSessions.compactMap { $0.id }
                let mainRequest = GameSession.fetchRequest()
                mainRequest.predicate = NSPredicate(format: "id IN %@", ids)
                mainRequest.sortDescriptors = [NSSortDescriptor(keyPath: \GameSession.startDate, ascending: false)]
                sessions = try await viewContext.fetch(mainRequest)
            } else {
                sessions = backgroundSessions
            }
            
            objectWillChange.send()
        } catch {
            self.error = error
            throw error
        }
    }
    
    func addSession(_ session: GameSession) {
        // Add to sessions list if not already present
        if !sessions.contains(where: { $0.id == session.id }) {
            sessions.insert(session, at: 0)
            objectWillChange.send()
        }
    }
    
    func removeSession(_ session: GameSession) {
        // Remove from sessions list
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions.remove(at: index)
            objectWillChange.send()
        }
    }
    
    // MARK: - Helper Methods
    
    enum AppStateError: Error {
        case coreDataNotInitialized
    }
}
