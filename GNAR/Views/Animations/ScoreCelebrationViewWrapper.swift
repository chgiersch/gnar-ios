//
//  ScoreCelebrationViewWrapper.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//

import SwiftUI

struct ScoreCelebrationViewWrapper: UIViewRepresentable {
    let score: Int
    let onComplete: () -> Void
    
    func makeUIView(context: Context) -> ScoreCelebrationView {
        let view = ScoreCelebrationView(score: score)
        view.startCelebration()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            onComplete()
        }
        
        return view
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: ScoreCelebrationView, context: Context) -> CGSize {
        return CGSize(width: 200, height: 100)
    }
}

// Preview provider for testing
struct ScoreCelebrationViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.opacity(0.5)
            ScoreCelebrationViewWrapper(score: 50) {
                print("Animation completed!")
            }
        }
        .frame(width: 200, height: 200)
    }
} 