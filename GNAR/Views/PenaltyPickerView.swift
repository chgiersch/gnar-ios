//
//  PenaltyPickerView.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//


import SwiftUI

struct PenaltyPickerView: View {
    @StateObject private var viewModel: PenaltyPickerViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPenalties: [Penalty]

    init(allPenalties: [Penalty], selectedPenalties: Binding<[Penalty]>) {
        _viewModel = StateObject(wrappedValue: PenaltyPickerViewModel(
            allPenalties: allPenalties,
            selectedPenalties: selectedPenalties.wrappedValue
        ))
        _selectedPenalties = selectedPenalties
    }

    var body: some View {
        NavigationView {
            List(viewModel.allPenalties) { penalty in
                HStack {
                    Text(penalty.name)
                    Spacer()
                    Text("\(penalty.points)")
                    if viewModel.selectedPenalties.contains(where: { $0.id == penalty.id }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.toggle(penalty)
                }
            }
            .navigationTitle("Select Penalties")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedPenalties = viewModel.selectedPenalties
                        dismiss()
                    }
                }
            }
        }
    }
}
