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
    
    @Published var selectedMountain: Mountain?
    @Published var playerNames: [String] = [""]  // Start with one empty field
    @Published var error: Error?
    @Published var isLoading = false
    @Published var availableMountains: [Mountain] = []
    
    private let viewContext: NSManagedObjectContext
    private let gameState: GameState
    
    // MARK: - Computed Properties
    
    var canStartGame: Bool {
        selectedMountain != nil && !playerNames.isEmpty && !playerNames.allSatisfy { $0.isEmpty }
    }
    
    // MARK: - Initialization
    
    init(viewContext: NSManagedObjectContext, gameState: GameState) {
        self.viewContext = viewContext
        self.gameState = gameState
    }
    
    // MARK: - Actions
    
    func loadMountains() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = Mountain.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Mountain.name, ascending: true)
            ]
            availableMountains = try await viewContext.fetch(request)
            
            // Select Free Range if it exists, otherwise select first mountain
            if let freeRange = availableMountains.first(where: { $0.name == "Free Range" }) {
                selectedMountain = freeRange
            } else if let firstMountain = availableMountains.first {
                selectedMountain = firstMountain
            }
        } catch {
            self.error = error
        }
    }
    
    func addPlayerField() {
        playerNames.append("")
    }
    
    func startGame() async throws -> GameSession {
        guard let mountain = selectedMountain else {
            throw GameError.mountainNotSelected
        }
        
        guard !playerNames.isEmpty else {
            throw GameError.noPlayersSelected
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Create players
        let players: [Player] = playerNames.compactMap { name in
            guard !name.isEmpty else { return nil }
            let player = Player(context: viewContext)
            player.id = UUID()
            player.name = name
            return player
        }
        
        try viewContext.save()
        return try await gameState.startNewSession(mountain: mountain, players: players)
    }
}

enum GameError: LocalizedError {
    case mountainNotSelected
    case noPlayersSelected
    
    var errorDescription: String? {
        switch self {
        case .mountainNotSelected:
            return "Please select a mountain"
        case .noPlayersSelected:
            return "Please add at least one player"
        }
    }
}
