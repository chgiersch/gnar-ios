//
//  PenaltyPickerViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/6/25.
//


import Foundation
import SwiftUI

@MainActor
final class PenaltyPickerViewModel: ObservableObject {
    let allPenalties: [Penalty]
    @Published var selectedPenalties: [Penalty]

    init(allPenalties: [Penalty], selectedPenalties: [Penalty]) {
        self.allPenalties = allPenalties
        self.selectedPenalties = selectedPenalties
    }

    func toggle(_ penalty: Penalty) {
        if selectedPenalties.contains(where: { $0.id == penalty.id }) {
            selectedPenalties.removeAll { $0.id == penalty.id }
        } else {
            selectedPenalties.append(penalty)
        }
    }
}