//
//  SeedVersionManager.swift
//  GNAR
//
//  Created by Chris Giersch on 4/5/25.
//


import Foundation

struct SeedVersionManager {
    static let shared = SeedVersionManager()

    private let defaults = UserDefaults.standard

    /// Get the stored version for a given seed ID (e.g., "global", "squallywood-mountain")
    func storedVersion(for id: String) -> String? {
        defaults.string(forKey: versionKey(for: id))
    }

    /// Check if a newer version should be loaded
    func shouldLoadSeed(for id: String, newVersion: String) -> Bool {
        guard let stored = storedVersion(for: id) else {
            return true // No version saved yet
        }
        return stored != newVersion
    }

    /// Save the version after loading
    func markVersion(_ version: String, for id: String) {
        defaults.set(version, forKey: versionKey(for: id))
        print("📦 Stored seed version '\(version)' for '\(id)'")
    }

    /// Clears version for a specific seed (dev only)
    func resetVersion(for id: String) {
        defaults.removeObject(forKey: versionKey(for: id))
    }

    /// Wipes all saved seed versions (dev only)
    func resetAllVersions() {
        for key in defaults.dictionaryRepresentation().keys where key.hasSuffix("DataVersion") {
            defaults.removeObject(forKey: key)
        }
        print("🧽 All seed versions cleared")
    }

    private func versionKey(for id: String) -> String {
        return "\(id)DataVersion"
    }
}
