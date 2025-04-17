//
//  ContentView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: ContentViewModel
    
    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $viewModel.selectedTab) {
                HomeView()
                    .tag(ContentViewModel.Tab.home)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                GamesView(contentViewModel: viewModel)
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
            .onAppear {
                print("📱 ContentView appeared at", Date())
                Task { @MainActor in
                    viewModel.sessionPreviews = []
                    viewModel.visibleSessions = []
                    viewModel.isLoadingSessions = true
                    await viewModel.loadSessionsIfNeeded()
                }
            }
            .onChange(of: viewModel.selectedTab) { oldTab, newTab in
                if newTab == .games {
                    Task { @MainActor in
                        await viewModel.loadSessionsIfNeeded()
                    }
                }
            }
        }
    }
}

#Preview {
    //    ContentView()
}
