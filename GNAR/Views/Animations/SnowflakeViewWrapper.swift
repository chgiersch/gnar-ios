//
//  SnowflakeViewWrapper.swift
//  GNAR
//
//  SwiftUI wrapper for our CoreAnimation snowflake tutorial

import SwiftUI

struct SnowflakeViewWrapper: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SnowflakeView {
        let view = SnowflakeView()
        return view
    }
    
    func updateUIView(_ uiView: SnowflakeView, context: Context) {
        // No updates needed for this simple version
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