//
//  LineWorthPickerViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//

import SwiftUI
import CoreData

class LineWorthPickerViewModel: ObservableObject {
    @Published var allLineWorths: [LineWorth] = []
    @Published var selectedLineWorth: LineWorth?
    @Published var selectedSnowLevel: SnowLevel = .medium

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext, selectedLineWorth: LineWorth? = nil, selectedSnowLevel: SnowLevel = .medium) {
        self.context = context
        self.selectedLineWorth = selectedLineWorth
        self.selectedSnowLevel = selectedSnowLevel
        fetchLineWorths(context: context)
    }

    private func fetchLineWorths(context: NSManagedObjectContext) {
        let request: NSFetchRequest<LineWorth> = LineWorth.fetchRequest()
        do {
            allLineWorths = try context.fetch(request)
        } catch {
            print("Failed to fetch LineWorths: \(error)")
        }
    }

    func select(_ line: LineWorth) {
        selectedLineWorth = line
    }

    func clearSelection() {
        selectedLineWorth = nil
    }
}
