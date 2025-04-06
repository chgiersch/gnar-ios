//
//  PenaltyPickerView.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//


import SwiftUI

struct PenaltyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let allPenalties: [Penalty]
    @Binding var selectedPenalties: [String]
    
    var body: some View {
        NavigationView {
            List(allPenalties) { penalty in
                HStack {
                    Text(penalty.name)
                    Spacer()
                    Text("\(penalty.points)")
                    if selectedPenalties.contains(penalty.id) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedPenalties.contains(penalty.id) {
                        selectedPenalties.removeAll { $0 == penalty.id }
                    } else {
                        selectedPenalties.append(penalty.id)
                    }
                }
            }
            .navigationTitle("Select Penalties")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
