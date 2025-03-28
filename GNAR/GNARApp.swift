//
//  GNARApp.swift
//  GNAR
//
//  Created by Chris Giersch on 3/28/25.
//

import SwiftUI

@main
struct GNARApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
