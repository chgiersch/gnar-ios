//
//  ContentViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import SwiftUI
import CoreData

class ContentViewModel: ObservableObject {
    let gamesViewModel: GamesViewModel
    
    let viewContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    
    @Published var selectedTab: Tab = .home {
        didSet {
            if ![.home, .games, .profile].contains(selectedTab) {
                print("❗ Invalid tab selected. Reverting to .home")
                selectedTab = .home
            }
        }
    }
    
    init(coreData: CoreDataContexts) {
        self.viewContext = coreData.viewContext
        self.backgroundContext = coreData.backgroundContext
        
        self.gamesViewModel = GamesViewModel(
            coreData: coreData,
            sessionFetcher: DefaultSessionFetcher()
        )
    }
    
    enum Tab: Hashable {
        case home, games, profile
    }
}

extension NSNotification.Name {
    static let loadGameSessions = NSNotification.Name("loadGameSessions")
}
