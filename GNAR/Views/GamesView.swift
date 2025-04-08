//
//  GamesView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//


import SwiftUI
import CoreData

struct GamesView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: GamesViewModel
    @EnvironmentObject var contentViewModel: ContentViewModel
    @State private var showingGameBuilder = false
    
    var body: some View {
        Form {
            /// 📦 Title section
            Section {
                Text("My Games")
                    .font(.title2.bold())
            }

            /// 🕹️ Session list
            Section(header: Text("Game Sessions")) {
                if viewModel.sessionPreviews.isEmpty {
                    Text("No games yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.sessionPreviews) { session in
                        Button {
                            contentViewModel.loadSession(by: session.id)
                        } label: {
                            sessionRow(session)
                        }
                    }
                }
            }

            /// ➕ New Game Button
            Section {
                Button(action: {
                    viewModel.showingGameBuilder = true
                }) {
                    HStack {
                        Spacer()
                        Text("Start New Game")
                            .font(.headline)
                            .padding(.vertical, 8)
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingGameBuilder) {
            GameBuilderView(
                coreData: viewModel.coreData,
                mountains: contentViewModel.mountainPreviews
            ) { newSession in
                contentViewModel.activeSession = newSession
                Task {
                    await viewModel.loadIfNeeded()
                }
            }
        }
        .fullScreenCover(item: $contentViewModel.activeSession) { session in
            GameDashboardView(session: session)
        }
        .overlay {
            if viewModel.isLoading {
                loadingState(text: "Loading games...")
                    .background(.thinMaterial)
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
    
    private func sessionRow(_ session: GameSessionPreview) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(session.mountainName)
                    .font(.headline)
                Spacer()
                Text("\(session.playerCount) player\(session.playerCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !session.playerNames.isEmpty {
                Text("👥 " + session.playerNames.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("🕓 \(session.date.formatted(.dateTime.month().day().hour().minute()))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}
