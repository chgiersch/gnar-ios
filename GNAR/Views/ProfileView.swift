//
//  ProfileView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile Settings")
                    .font(.largeTitle)
                    .padding()
                
                Text("Edit Profile and View Progress") // Placeholder
                
                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    let coreDataStack = CoreDataStack.preview
    let appState = AppStateManager(coreDataStack: coreDataStack)
    
    return ProfileView()
        .environmentObject(appState)
}
