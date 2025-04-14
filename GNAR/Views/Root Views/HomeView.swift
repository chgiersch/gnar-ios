//
//  HomeView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//


import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Welcome to GNAR!")
                .font(.largeTitle)
                .padding()
            
            Text("Your All-Time GNAR Score: 0") // Placeholder
            
            Spacer()
        }
        .navigationTitle("Home")
    }
}

#Preview {
    HomeView()
}
