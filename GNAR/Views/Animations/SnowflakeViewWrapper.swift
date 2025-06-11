//
//  SnowflakeViewWrapper.swift
//  GNAR
//
//  SwiftUI wrapper for SnowflakeView with scroll-responsive storm intensity

import SwiftUI

struct SnowflakeViewWrapper: UIViewRepresentable {
    
    /// Scroll progress from 0.0 (top) to 1.0 (bottom)
    let scrollProgress: CGFloat
    
    init(scrollProgress: CGFloat = 0.0) {
        self.scrollProgress = scrollProgress
    }
    
    func makeUIView(context: Context) -> SnowflakeView {
        let view = SnowflakeView()
        return view
    }
    
    func updateUIView(_ uiView: SnowflakeView, context: Context) {
        // Update storm intensity based on scroll position
        uiView.adjustStormIntensity(scrollProgress: scrollProgress)
    }
}

// MARK: - Preview for Testing

#Preview {
    ZStack {
        // Dark background to see white snowflakes
        Color.black.opacity(0.8)
            .ignoresSafeArea()
        
        SnowflakeViewWrapper()
            .frame(width: 300, height: 500)
    }
} 