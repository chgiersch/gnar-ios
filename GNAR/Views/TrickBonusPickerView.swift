//
//  TrickBonusPickerView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/31/25.
//


import SwiftUI

struct TrickBonusPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let allTrickBonuses: [TrickBonus]
    @Binding var selectedBonuses: [TrickBonus]
    
    @State private var newTrickBonuses: [TrickBonus] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allTrickBonuses) { bonus in
                    HStack {
                        Text("\(bonus.name) (+\(bonus.points))")
                        Spacer()
                        if newTrickBonuses.contains(where: { $0.id == bonus.id }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggle(bonus)
                    }
                }
            }
            .navigationTitle("Trick Bonuses")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        selectedBonuses.append(contentsOf: newTrickBonuses)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Clear selection to allow duplicates on every open
            newTrickBonuses = []
        }
    }
    
    private func toggle(_ bonus: TrickBonus) {
        if newTrickBonuses.contains(where: { $0.id == bonus.id }) {
            newTrickBonuses.removeAll(where: { $0.id == bonus.id })
        } else {
            newTrickBonuses.append(bonus)
        }
    }
}

#Preview {
    
}
