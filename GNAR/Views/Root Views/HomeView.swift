//
//  HomeView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//


import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Fixed header
            VStack(spacing: 0) {
                Text("GNAR")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 16)                
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            
            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Welcome to GNAR!")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    
                    // How to Play section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to Play GNAR")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("""
                        GNAR is a game about doing rad stuff, calling your shot, and giving your ego a wedgie.

                        Every player earns points by skiing, snowboarding, or generally sending it — and by doing silly, embarrassing, or downright ridiculous things that prove you don't take yourself too seriously.

                        This is a game of honor. Call your points when you do them. Let your crew verify. Be real. Be ridiculous. Be GNAR.
                        """)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Scoring Categories section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Scoring Categories")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("""
                        • Line Worths – Earn points for sending lines. Some lines are worth more based on snow conditions.
                        • Trick Bonuses – Stack points with tricks (360s, grabs, backflips, etc.).
                        • ECPs (Extra Credit Points) – Embarrassing dares, tram farts, yelling "Hey Mom!" from the lift, etc.
                        • Penalties – Lose points for things like calling the wrong line, ego trips, or forgetting to record.

                        There are two scoring systems:
                        • GNAR Score – All points are positive (even penalties, because they're funny).
                        • Pro Score – Penalties subtract from your total, like a true comp.
                        """)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Gameplay section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gameplay")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("""
                        1. Start a game with your friends.
                        2. Choose a mountain or go Free Range.
                        3. Add players and start scoring.

                        You can log points:
                        • Manually – on lift rides or breaks.
                        • With Voice – call out what you did and let the app log it.

                        Whoever has the most points at the end of the day… wins nothing, but earns bragging rights.
                        """)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Rules section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rules of GNAR")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("""
                        • Self-deprecation is power. You earn respect by embarrassing yourself in public with confidence.
                        • Call your line before you drop. If you don't ski what you claimed, you lose points.
                        • Style over everything. It's not just what you do — it's how you do it.
                        • You don't actually win anything. Except legend status.
                        • Don't fake points. That's not GNAR. That's lame.
                        """)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Add bottom padding to account for tab bar
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 24)
            }
        }
        .navigationBarHidden(true)
        .navigationTitle("Home")
    }
}

#Preview {
    HomeView()
}
