//
//  LoadingScreen.swift
//  GNAR
//
//  Created by Chris Giersch on 4/7/25.
//

import SwiftUI

struct LoadingScreen: View {
    @EnvironmentObject private var launchManager: LaunchStateManager
    @State private var skiAngle: Double = 0
    @State private var boardAngle: Double = 0
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // ~60 FPS

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 36) {
                Text("GNAR")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .tracking(4)
                    .foregroundColor(.accentColor)
                    .shadow(color: .accentColor.opacity(0.4), radius: 8, x: 0, y: 4)

                HStack(spacing: 40) {
                    Image(systemName: "figure.skiing.downhill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(skiAngle))

                    Image(systemName: "figure.snowboarding")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(boardAngle))
                }
                
                VStack(spacing: 8) {
                    ProgressView(value: launchManager.loadingProgress, total: 1.0)
                        .frame(width: 200)
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(.accentColor)
                    
                    Text(launchManager.loadingMessage)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            .onReceive(timer) { _ in
                skiAngle += 2
                boardAngle -= 2
            }
        }
    }
}

// Preview
#Preview {
    LoadingScreen()
        .environmentObject(LaunchStateManager(
            coreData: CoreDataContexts(
                viewContext: PersistenceController.preview.container.viewContext,
                backgroundContext: PersistenceController.preview.container.newBackgroundContext()
            ),
            appState: AppState()
        ))
}
