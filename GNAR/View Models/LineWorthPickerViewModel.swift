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
    @Published private(set) var groupedLines: [AreaGroup] = []
    
    struct AreaGroup: Identifiable {
        let id: String
        let area: String
        let lines: [LineWorth]
    }
    
    init(context: NSManagedObjectContext, selectedLine: LineWorth?, selectedSnowLevel: SnowLevel) {
        self.context = context
        loadLines()
    }
    
    private func loadLines() {
        let request = LineWorth.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LineWorth.name, ascending: true)]
        
        do {
            lines = try context.fetch(request)
            updateGroupedLines()
        } catch {
            print("Error loading lines: \(error)")
        }
    }
    
    private func updateGroupedLines() {
        let grouped = Dictionary(grouping: lines) { $0.area }

        let sortedAreas = grouped.map { (area, lines) in
            let sortedLines = lines.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            return AreaGroup(id: area, area: area, lines: sortedLines)
        }

        groupedLines = sortedAreas.sorted {
            $0.area.localizedCaseInsensitiveCompare($1.area) == .orderedAscending
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
