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

    var body: some View {
        printRender("🧱 GamesView body rendered at")

        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    // 📦 Title
                    Text("My Games")
                        .font(.largeTitle.bold())
                        .padding(.top, 24)
                        .frame(maxWidth: .infinity, alignment: .center)

                    // 🕹️ Session List
                    sessionSection()
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }

            // ➕ Start New Game Button
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
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80) // adds space under button
            }
        }
        .sheet(isPresented: $contentViewModel.showingGameBuilder) {
            GameBuilderView(
                coreData: contentViewModel.coreData,
                mountains: contentViewModel.mountainPreviews
            ) { newSession in
                contentViewModel.activeSession = newSession
                Task {
                    await contentViewModel.loadInitialSessions()
                }
            }
        }
        .fullScreenCover(item: $contentViewModel.activeSession) { session in
            GameDashboardView(session: session)
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
        switch contentViewModel.visibleSessions {
        case nil:
            loadingState(text: "Loading your games...")

        case let sessions? where sessions.isEmpty:
            Text("No games yet.")
                .foregroundColor(.gray)

        case let sessions?:
            LazyVStack(spacing: 16) {
                ForEach(sessions) { session in
                    Button {
                        contentViewModel.loadSession(by: session.id)
                    } label: {
                        sessionRow(for: session)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }

                    if sessions.count < (contentViewModel.sessionPreviews?.count ?? 0) {
                        Button("Load More") {
                            contentViewModel.loadMoreSessions()
                        }
                        .padding(.vertical)
                    }
                }
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

    private func sessionRow(for preview: GameSessionPreview) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(preview.mountainName)
                    .font(.headline)
                Spacer()
                Text("\(preview.playerCount) player\(preview.playerCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("🕓 \(preview.date.formatted(.dateTime.month().day().hour().minute()))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    @discardableResult
    func printRender(_ message: String) -> EmptyView {
        print(message, Date())
        return EmptyView()
    }
}
