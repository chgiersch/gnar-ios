//
//  GameBuilderViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//


import Foundation
import SwiftUI
import CoreData

@MainActor
class GameBuilderViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var playerNames: [String] = [""]
    @Published var selectedMountain: String = "Free Range"
    @Published var error: Error?
    @Published var isLoading = false
    
    private let viewContext: NSManagedObjectContext
    
    // MARK: - Computed Properties
    
    var canStartGame: Bool {
        !selectedMountain.isEmpty && 
        playerNames.count >= 1 && 
        playerNames.allSatisfy { !$0.isEmpty }
    }
    
    // MARK: - Initialization
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    // MARK: - Methods
    
    func addPlayerField() {
        playerNames.append("")
    }
    
    func startGame() async throws -> GameSession {
        print("🎮 Starting game creation...")
        
        // Create the game session
        let gameSession = GameSession(context: viewContext)
        gameSession.id = UUID()
        gameSession.mountainName = selectedMountain
        gameSession.startDate = Date()
        
        print("🎮 Created game session with ID: \(gameSession.id.uuidString)")
        print("🎮 Mountain: \(gameSession.mountainName)")
        
        // Create and add players
        for name in playerNames {
            print("🎮 Creating player: \(name)")
            let player = Player(context: viewContext)
            player.id = UUID()
            player.name = name
            gameSession.addToPlayers(player)
            player.addToGameSessions(gameSession)
        }
        
        print("🎮 Total players added: \(gameSession.playersArray.count)")
        
        print("🎮 Attempting to save context...")
        do {
            try viewContext.save()
            print("🎮 Context saved successfully")
            return gameSession
        } catch {
            print("🎮 Error saving context: \(error)")
            // Rollback changes if save fails
            viewContext.rollback()
            throw error
        }
    }
}
