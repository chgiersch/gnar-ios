//
//  ECPPickerView.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//


import SwiftUI

struct ECPPickerView: View {
    @StateObject private var viewModel: ECPPickerViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedECPs: [ECP]
    
    init(allECPs: [ECP], selectedECPs: Binding<[ECP]>) {
        _viewModel = StateObject(wrappedValue: ECPPickerViewModel(
            allECPs: allECPs,
            selectedECPs: selectedECPs.wrappedValue
        ))
        _selectedECPs = selectedECPs
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.allECPs) { ecp in
                HStack {
                    VStack(alignment: .leading) {
                        Text(ecp.name)
                        Text(ecp.descriptionText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(ecp.points)")
                    if viewModel.selectedECPs.contains(where: { $0.id == ecp.id }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.toggle(ecp)
                }
            }
            .navigationTitle("Select ECPs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedECPs = viewModel.selectedECPs
                        dismiss()
                    }
                }
            }
        }
    }
}
