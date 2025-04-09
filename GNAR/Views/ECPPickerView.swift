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
    @State private var selectedFrequency: ECPFrequency = .daily
    
    enum ECPFrequency: String, CaseIterable {
        case daily = "Daily"
        case yearly = "Yearly"
        case unlimited = "Unlimited"
    }
    
    init(allECPs: [ECP], selectedECPs: Binding<[ECP]>) {
        _viewModel = StateObject(wrappedValue: ECPPickerViewModel(
            allECPs: allECPs,
            selectedECPs: selectedECPs.wrappedValue
        ))
        _selectedECPs = selectedECPs
    }
    

    var filteredECPs: [ECP] {
        viewModel.allECPs.filter { ecp in
            (ecp.frequency).localizedCaseInsensitiveCompare(selectedFrequency.rawValue) == .orderedSame
        }
    }

    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Frequency", selection: $selectedFrequency) {
                    ForEach(ECPFrequency.allCases, id: \.self) { freq in
                        Text(freq.rawValue).tag(freq)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List(filteredECPs) { ecp in
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        selectedECPs = []
                        dismiss()
                    }
                }
            }
        }
    }
}
