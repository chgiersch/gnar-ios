//
//  LoadingScreen.swift
//  GNAR
//
//  Created by Chris Giersch on 4/7/25.
//


import SwiftUI

struct LoadingScreen: View {
    @State private var rotateSki = false
    @State private var rotateBoard = false

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
                        .rotationEffect(.degrees(rotateSki ? 360 : 0))
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: rotateSki)

                    Image(systemName: "figure.snowboarding")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(rotateBoard ? -360 : 0))
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false), value: rotateBoard)
                }

                ProgressView("Loading Mountains...")
                    .font(.headline)
                    .padding(.top, 8)
            }
            .onAppear {
                rotateSki = true
                rotateBoard = true
            }
        }
    }
}
