import SwiftUI

struct CelebrationPositionModifier: ViewModifier {
    let showCelebration: Bool
    let celebrationScore: Int
    let onComplete: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if showCelebration {
                    ScoreCelebrationViewWrapper(score: celebrationScore, onComplete: onComplete)
                }
            }
    }
}

extension View {
    func celebrationOverlay(
        show: Bool,
        score: Int,
        onComplete: @escaping () -> Void
    ) -> some View {
        modifier(CelebrationPositionModifier(
            showCelebration: show,
            celebrationScore: score,
            onComplete: onComplete
        ))
    }
} 