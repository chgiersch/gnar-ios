//
//  ProfileView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//


import SwiftUI

struct ProfileView: View {
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
    ProfileView()
}
