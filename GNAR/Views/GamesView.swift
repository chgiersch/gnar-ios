//
//  GamesView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//


import SwiftUI
import CoreData

struct GamesView: View {
    @StateObject private var viewModel: GamesViewModel
    
    init(viewModel: GamesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading games...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if viewModel.sessionPreviews.isEmpty {
                    Text("No games yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.sessionPreviews) { session in
                        VStack(alignment: .leading) {
                            Text(session.mountainName)
                                .font(.headline)
                            Text("Started on \(session.date.formatted(.dateTime.month().day().hour().minute()))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }

            Spacer()

            Button(action: {
                viewModel.showingGameBuilder = true
            }) {
                Label("New Game", systemImage: "plus")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Games")
        .sheet(isPresented: $viewModel.showingGameBuilder) {
            GameBuilderView(context: viewModel.viewContext) { session in
                viewModel.activeSession = session
                Task {
                    await viewModel.loadSessions()
                }
            }
        }
        .fullScreenCover(item: $viewModel.activeSession) { session in
            GameDashboardView(session: session)
        }
        .onAppear {
            Task {
                await viewModel.loadIfNeeded()
            }
        }
    }
}

#Preview {
    
}
