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
        NavigationStack {
            TabView(selection: $viewModel.selectedTab) {
                HomeView()
                    .tag(ContentViewModel.Tab.home)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                GamesView(viewModel: viewModel.gamesViewModel)
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
                print("🟢 ContentView appeared.")
            }
            .onChange(of: viewModel.selectedTab) { oldTab, newTab in
                print("🔄 Tab changed from \(oldTab) to \(newTab)")
                if newTab == .games {
                    print("📦 Games tab selected. Session count: \(viewModel.gamesViewModel.sessionPreviews.count)")
                }
            }
        }
    }
}

#Preview {
    //    ContentView()
}
