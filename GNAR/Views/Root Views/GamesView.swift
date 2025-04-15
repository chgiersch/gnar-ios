//
//  GamesView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//


import SwiftUI
import CoreData

struct GamesView: View {
    @ObservedObject var contentViewModel: ContentViewModel
    @State private var selectedSession: GameSession?
    @State private var showGameDashboard: Bool = false

    var body: some View {
        printRender("🧱 GamesView body rendered at")

        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    Text("My Games")
                        .font(.largeTitle.bold())
                        .padding(.top, 24)
                        .frame(maxWidth: .infinity, alignment: .center)

                    sessionSection()
                        .padding(.horizontal)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    contentViewModel.showingGameBuilder = true
                }) {
                    Text("Start New Game")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
                .accessibilityIdentifier("New Game")
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $contentViewModel.showingGameBuilder) {
            GameBuilderView(
                viewContext: contentViewModel.coreDataStack.viewContext,
                onGameCreated: { gameSession in
                    // Update the selected session and show the dashboard
                    selectedSession = gameSession
                    // Refresh the sessions list
                    Task {
                        await contentViewModel.loadSessionsIfNeeded()
                    }
                }
            )
        }
        .fullScreenCover(item: $selectedSession) { session in
            let viewModel = GameDashboardViewModel(session: session, viewContext: contentViewModel.coreDataStack.viewContext)
            GameDashboardView(viewModel: viewModel)
        }
        .overlay {
            if contentViewModel.isLoadingSessions {
                loadingState(text: "Loading games...")
                    .background(.thinMaterial)
            }
        }
    }

    @ViewBuilder
    private func sessionSection() -> some View {
        VStack(alignment: .leading) {
            if contentViewModel.isLoadingSessions {
                loadingSection()
            } else if let sessions = contentViewModel.visibleSessions, !sessions.isEmpty {
                sessionsList(sessions)
            } else {
                emptyStateView()
            }
        }
    }

    private func loadingSection() -> some View {
        VStack {
            ProgressView()
                .padding()
            Text("Loading games...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func emptyStateView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.bottom, 8)
            
            Text("No games yet")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Start a new game to begin tracking scores")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func sessionsList(_ sessions: [GameSessionPreview]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(sessions) { session in
                SessionRow(session: session)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await contentViewModel.loadSession(id: session.id)
                            selectedSession = contentViewModel.selectedSession
                        }
                    }
            }
            
            if (contentViewModel.sessionPreviews?.count ?? 0) > contentViewModel.visibleSessions?.count ?? 0 {
                Button("Load More") {
                    contentViewModel.loadMoreSessions()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
    }

    private func loadingState(text: String) -> some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(text)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @discardableResult
    func printRender(_ message: String) -> EmptyView {
        print(message, Date())
        return EmptyView()
    }
}

struct SessionRow: View {
    let session: GameSessionPreview
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.mountainName)
                    .font(.headline)
                
                Text("\(session.playerCount) players")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("🕓 \(formattedDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.startDate)
    }
}

// For SwiftUI previews
#Preview {
    GamesView(contentViewModel: ContentViewModel(coreDataStack: CoreDataStack.preview))
}
