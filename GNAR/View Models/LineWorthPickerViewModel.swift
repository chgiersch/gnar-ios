//
//  LineWorthPickerViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
final class LineWorthPickerViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var lines: [LineWorth] = []
    
    init(context: NSManagedObjectContext, selectedLine: LineWorth?, selectedSnowLevel: SnowLevel) {
        self.context = context
        loadLines()
    }
    
    private func loadLines() {
        let request = LineWorth.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LineWorth.name, ascending: true)]
        
        do {
            lines = try context.fetch(request)
        } catch {
            print("Error loading lines: \(error)")
        }
    }

    /// Sets the selected line to the one the user tapped
    func select(_ line: LineWorth) {
        // Implementation needed
    }

    func clearSelection() {
        // Implementation needed
    }
}
