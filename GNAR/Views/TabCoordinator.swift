//
//  TabCoordinator.swift
//  GNAR
//
//  Created by Chris Giersch on 4/6/25.
//


import SwiftUI
import CoreData

class TabCoordinator: ObservableObject {
    enum Tab: Hashable {
        case home, games, profile
    }

    @Published var selectedTab: Tab = .home
    @Published var profileViewModel = ProfileViewModel()
    
    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.backgroundContext = backgroundContext
    }

    func makeGamesViewModel() -> GamesViewModel {
        return GamesViewModel(viewContext: viewContext, backgroundContext: backgroundContext)
    }
}

// MARK: - Sample ViewModels

class HomeViewModel: ObservableObject {
    // Placeholder for home-specific logic
}

class ProfileViewModel: ObservableObject {
    // Placeholder for profile-specific logic
}
