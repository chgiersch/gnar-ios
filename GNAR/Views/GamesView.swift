//
//  GamesView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//


import SwiftUI
import CoreData

struct GamesView: View {
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject var appState: AppStateManager
    @State private var selectedSession: GameSession?
    @State private var showingGameDashboard = false
    
    @StateObject private var dashboardViewModel = GameDashboardViewModel(gameState: nil)
    
    var body: some View {
        NavigationStack {
            Group {
                if appState.isLoadingSessions && appState.visibleSessions.isEmpty {
                    ProgressView()
                } else if appState.visibleSessions.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(appState.visibleSessions) { session in
                            NavigationLink {
                                GameDashboardView(viewModel: dashboardViewModel)
                                    .onAppear {
                                        // Update the gameState and load the session
                                        dashboardViewModel.gameState = viewModel.gameState
                                        Task {
                                            await dashboardViewModel.loadSession(session)
                                        }
                                    }
                            } label: {
                                SessionRow(session: GameSessionPreview(from: session))
                            }
                        }
                        
                        if appState.isLoadingSessions {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Games")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await viewModel.createNewGame()
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingGameBuilder) {
                GameBuilderView(
                    viewContext: viewModel.gameState.viewContext,
                    gameState: viewModel.gameState
                ) { gameSession in
                    Task {
                        print("New game created, transitioning to game dashboard")
                        
                        // First load the session in ContentViewModel to update the list
                        await viewModel.loadSession(gameSession)
                        
                        // Make sure the builder is dismissed first
                        viewModel.showingGameBuilder = false
                        
                        // Set up the dashboard view model with the game state
                        dashboardViewModel.gameState = viewModel.gameState
                        
                        // Set the selected session and immediately load it
                        selectedSession = gameSession
                        await dashboardViewModel.loadSession(gameSession)
                        
                        showingGameDashboard = true
                    }
                }
            }
            .sheet(isPresented: $showingGameDashboard) {
                // Use the shared view model for the dashboard
                NavigationStack {
                    GameDashboardView(viewModel: dashboardViewModel)
                }
            }
            .task {
                if appState.sessions.isEmpty {
                    do {
                        try await appState.loadSessionsIfNeeded()
                    } catch {
                        print("Failed to load sessions: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

struct SessionRow: View {
    let session: GameSessionPreview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.mountainName)
                .font(.headline)
            
            Text(session.startDate.formatted(date: .long, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                ForEach(Array(zip(session.playerIds, session.playerNames)).prefix(3), id: \.0) { id, name in
                    Text(name)
                        .font(.caption)
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                
                if session.playerCount > 3 {
                    Text("+\(session.playerCount - 3)")
                        .font(.caption)
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Games Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start a new game to begin tracking scores")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    let coreDataStack = CoreDataStack.preview
    let appState = AppStateManager(coreDataStack: coreDataStack)
    let gameState = GameStateManager(viewContext: coreDataStack.viewContext, appState: appState)
    let viewModel = ContentViewModel(gameState: gameState, appState: appState)
    
    return GamesView(viewModel: viewModel)
        .environmentObject(gameState)
        .environmentObject(appState)
}
