//
//  GamesView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//


import SwiftUI
import CoreData

struct GamesView: View {
    @ObservedObject var viewModel: GamesViewModel
    @State private var selectedPreview: GameSessionPreview?
    
    var body: some View {
        ZStack {
            VStack {
                Text("Games")
                    .font(.largeTitle.bold())
                    .padding(.top)
                    .padding(.horizontal)

                Divider()

                List {
                    if viewModel.sessionPreviews.isEmpty {
                        Text("No games yet.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.sessionPreviews) { session in
                            Button {
                                selectedPreview = session
                            } label: {
                                sessionRow(session)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            
            if viewModel.isLoading {
                loadingState(text: "Loading games...")
                    .background(.thinMaterial)
            }
        }
        .task {
            await viewModel.loadIfNeeded()
        }
        .sheet(isPresented: $viewModel.showingGameBuilder) {
            GameBuilderView(coreData: viewModel.coreData) { newSession in
                Task {
                    await viewModel.loadIfNeeded()
                }
            }
        }
        .overlay(alignment: .bottom) {
            Button(action: {
                viewModel.showingGameBuilder = true
            }) {
                Text("Start New Game")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .padding(.bottom, 12)
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
