//
//  ContentViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/3/25.
//


import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var selectedTab: Tab = .home
    
    enum Tab {
        case home, games, profile
    }
}

extension NSNotification.Name {
    static let loadGameSessions = NSNotification.Name("loadGameSessions")
}
