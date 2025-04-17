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
        GeometryReader { geometry in
            ZStack {
                Image("GNAR_Cover")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(Color.black.opacity(0.4))
                
                VStack(spacing: 36) {
                    Text("GNAR")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .tracking(4)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)
                    
                    HStack(spacing: 40) {
                        Image(systemName: "figure.skiing.downhill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(skiAngle))
                        
                        Image(systemName: "figure.snowboarding")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(boardAngle))
                    }
                    
                    VStack(spacing: 8) {
                        ProgressView(value: launchManager.loadingProgress, total: 1.0)
                            .frame(width: 200)
                            .progressViewStyle(LinearProgressViewStyle())
                            .tint(.white)
                        
                        Text(launchManager.loadingMessage)
                            .font(.headline)
                            .foregroundColor(.white)
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
}

// Preview
#Preview {
    LoadingScreen()
        .environmentObject(LaunchStateManager(
            coreDataStack: CoreDataStack.preview,
            appState: AppState()
        ))
}
