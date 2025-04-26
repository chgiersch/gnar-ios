//
//  ContentViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import SwiftUI
import CoreData

@MainActor
class ContentViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var selectedTab: Tab = .home
    @Published var showingGameBuilder = false
    
    @Published var gameState: GameState
    @Published var appState: AppState
    
    // MARK: - Tab Selection

    enum Tab {
        case home
        case games
        case profile
    }
    // MARK: - Initialization

    init(gameState: GameState, appState: AppState) {
        self.gameState = gameState
        self.appState = appState
        
        // Load sessions in background when initialized
        Task {
            try? await appState.loadSessionsIfNeeded()
        }
    }
    
    var visibleSessions: [GameSession] {
        appState.visibleSessions
    }
    
    // MARK: - Sessions

    func loadSessionsIfNeeded() async throws {
        try await appState.loadSessionsIfNeeded()
    }
    
    func loadSessions() async throws {
        try await appState.loadSessions()
    }
    
    func loadSession(_ session: GameSession) async {
        do {
            try await gameState.loadSession(session)
            // Make sure session is in app state
            appState.addSession(session)
        } catch {
            appState.error = error
        }
    }
    
    // MARK: - Game Creation
    
    func createNewGame() async {
        showingGameBuilder = true
    }
}

extension NSNotification.Name {
    static let loadGameSessions = NSNotification.Name("loadGameSessions")
}
