//
//  TrickBonusPickerViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//


import Foundation
import SwiftUI

@MainActor
final class TrickBonusPickerViewModel: ObservableObject {
    let allTrickBonuses: [TrickBonus]
    @Published var selectedBonuses: [TrickBonus]
    @Published var newTrickBonuses: [TrickBonus] = []
    
    init(allTrickBonuses: [TrickBonus], selectedBonuses: [TrickBonus]) {
        self.allTrickBonuses = allTrickBonuses
        self.selectedBonuses = selectedBonuses
    }
    
    func toggle(_ bonus: TrickBonus) {
        if newTrickBonuses.contains(where: { $0.id == bonus.id }) {
            newTrickBonuses.removeAll(where: { $0.id == bonus.id })
        } else {
            newTrickBonuses.append(bonus)
        }
    }
    
    func confirmSelection() {
        selectedBonuses.append(contentsOf: newTrickBonuses)
        newTrickBonuses = []
    }
    
    func cancelSelection() {
        newTrickBonuses = []
    }
}
