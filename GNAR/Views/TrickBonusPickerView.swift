//
//  TrickBonusPickerView.swift
//  GNAR
//
//  Created by Chris Giersch on 3/31/25.
//


import SwiftUI

struct TrickBonusPickerView: View {
    @StateObject private var viewModel: TrickBonusPickerViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedBonuses: [TrickBonus]

    init(allTrickBonuses: [TrickBonus], selectedBonuses: Binding<[TrickBonus]>) {
        _viewModel = StateObject(wrappedValue: TrickBonusPickerViewModel(
            allTrickBonuses: allTrickBonuses,
            selectedBonuses: selectedBonuses.wrappedValue
        ))
        _selectedBonuses = selectedBonuses
    }

    var body: some View {
        NavigationView {
            List(viewModel.allTrickBonuses) { bonus in
                HStack {
                    Text("\(bonus.name) (+\(bonus.points))")
                    Spacer()
                    if viewModel.newTrickBonuses.contains(where: { $0.id == bonus.id }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.toggle(bonus)
                }
            }
            .navigationTitle("Trick Bonuses")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.confirmSelection()
                        selectedBonuses = viewModel.selectedBonuses
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelSelection()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.newTrickBonuses = []
        }
    }
}
#Preview {
    
}
