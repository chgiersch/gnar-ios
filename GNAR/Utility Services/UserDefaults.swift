//
//  Keys.swift
//  GNAR
//
//  Created by Chris Giersch on 4/7/25.
//


import Foundation

extension UserDefaults {
    private enum Keys {
        static let hasSeededMountains = "hasSeededMountains"
    }

    var hasSeededMountains: Bool {
        get { bool(forKey: Keys.hasSeededMountains) }
        set { set(newValue, forKey: Keys.hasSeededMountains) }
    }
}