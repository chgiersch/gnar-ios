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
    @Published var selectedECPs: [ECP]
    
    init(allECPs: [ECP], selectedECPs: [ECP]) {
        self.allECPs = allECPs
        self.selectedECPs = selectedECPs
    }
    
    func toggle(_ ecp: ECP) {
        if selectedECPs.contains(where: { $0.id == ecp.id }) {
            selectedECPs.removeAll { $0.id == ecp.id }
        } else {
            selectedECPs.append(ecp)
        }
    }
}
