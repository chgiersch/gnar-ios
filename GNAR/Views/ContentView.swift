//
//  ContentView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var tabCoordinator: TabCoordinator
    @StateObject private var gamesViewModel: GamesViewModel
    
    init(viewContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        _tabCoordinator = StateObject(wrappedValue: TabCoordinator(viewContext: viewContext, backgroundContext: backgroundContext))
        _gamesViewModel = StateObject(wrappedValue: GamesViewModel(viewContext: viewContext, backgroundContext: backgroundContext))
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $tabCoordinator.selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(TabCoordinator.Tab.home)
                
                GamesView(viewModel: gamesViewModel)
                    .tabItem {
                        Label("Games", systemImage: "gamecontroller")
                    }
                    .tag(TabCoordinator.Tab.games)
                
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
                    .tag(TabCoordinator.Tab.profile)
            }
            .onAppear {
                Task {
                    await gamesViewModel.loadIfNeeded()
                }
            }
        }
    }
}

#Preview {
//    ContentView()
}
