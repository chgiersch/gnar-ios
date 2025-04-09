//
//  RootView.swift
//  GNAR
//
//  Created by Chris Giersch on 4/8/25.
//


import SwiftUI

struct RootView: View {
    @ObservedObject var appState: AppState
    var contentViewModel: ContentViewModel?

    var body: some View {
        ZStack {
            if appState.isReady, let viewModel = contentViewModel {
                ContentView(viewModel: viewModel)
                    .environmentObject(viewModel)
                    .transition(.opacity)
            } else {
                LoadingScreen()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.isReady)
    }
}
