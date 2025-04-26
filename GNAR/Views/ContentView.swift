//
//  ContentView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        Group {
            if appState.isLoading {
                LoadingScreen()
                    .transition(.opacity)
            } else {
                MainTabView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.isLoading)
    }
}

// MARK: - MainTabView
struct MainTabView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeView()
                .tag(ContentViewModel.Tab.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            GamesView(viewModel: viewModel)
                .tag(ContentViewModel.Tab.games)
                .tabItem {
                    Label("Games", systemImage: "gamecontroller")
                }
            
            ProfileView()
                .tag(ContentViewModel.Tab.profile)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    // Create shared preview dependencies
    let coreDataStack = CoreDataStack.preview
    let appState = AppStateManager(coreDataStack: coreDataStack)
    let gameState = GameStateManager(viewContext: coreDataStack.viewContext, appState: appState)
    let viewModel = ContentViewModel(gameState: gameState, appState: appState)
    
    return ContentView(viewModel: viewModel)
        .environmentObject(gameState)
        .environmentObject(appState)
}
