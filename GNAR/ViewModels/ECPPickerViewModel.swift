//
//  ECPPickerViewModel.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//


import Foundation
import SwiftUI

@MainActor
final class ECPPickerViewModel: ObservableObject {
    let allECPs: [ECP]
    @Published var selectedECPs: [String]
    @Published var newECPs: [String] = []
    
    init(allECPs: [ECP], selectedECPs: [String]) {
        self.allECPs = allECPs
        self.selectedECPs = selectedECPs
    }
    
    func toggle(_ ecp: ECP) {
        if selectedECPs.contains(ecp.id) {
            selectedECPs.removeAll { $0 == ecp.id }
        } else {
            selectedECPs.append(ecp.id)
        }
    }
}
