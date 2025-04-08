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
    
    var body: some View {
        Group {
            ZStack {
                TabView(selection: $viewModel.selectedTab) {
                    ForEach([ContentViewModel.Tab.home, .games, .profile], id: \.self) { tab in
                        tabView(for: tab)
                            .tag(tab)
                            .tabItem {
                                switch tab {
                                case .home: Label("Home", systemImage: "house")
                                case .games: Label("Games", systemImage: "gamecontroller")
                                case .profile: Label("Profile", systemImage: "person.circle")
                                }
                            }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func tabView(for tab: ContentViewModel.Tab) -> some View {
        switch tab {
        case .home:
            NavigationStack { HomeView() }
            
        case .games:
            NavigationStack {
                GamesView(viewModel: viewModel.gamesViewModel)
            }
            
        case .profile:
            NavigationStack { ProfileView() }
        }
    }
}

#Preview {
    //    ContentView()
}
