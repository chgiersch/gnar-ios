//
//  AppState.swift
//  GNAR
//
//  Created by Chris Giersch on 5/4/25.
//

import Foundation
import CoreData
import SwiftUI

/// Protocol defining the core application state
@MainActor
protocol AppState: AnyObject {
    // MARK: - Core Properties
    var isLoading: Bool { get set }
    var mountainSeedingComplete: Bool { get set }
    var isLoadingSessions: Bool { get }
    var sessions: [GameSession] { get }
    var visibleSessions: [GameSession] { get }
    var error: Error? { get set }
    var viewContext: NSManagedObjectContext? { get }
    
    // MARK: - Sessions Management
    func loadSessionsIfNeeded() async throws
    func loadSessions() async throws
    func addSession(_ session: GameSession)
    func removeSession(_ session: GameSession)
    
    // MARK: - Setup
    func configure(with coreDataStack: CoreDataStack)
}
