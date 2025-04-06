//
//  LineWorthPickerView.swift
//  GNAR
//
//  Created by Chris Giersch on 4/2/25.
//

import SwiftUI
import CoreData

struct LineWorthPickerView: View {
    @StateObject private var viewModel: LineWorthPickerViewModel
    @Environment(\.dismiss) private var dismiss

    let onPick: (LineWorth, SnowLevel) -> Void

    init(
        context: NSManagedObjectContext,
        selectedLineWorth: LineWorth? = nil,
        selectedSnowLevel: SnowLevel = .medium,
        onPick: @escaping (LineWorth, SnowLevel) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: LineWorthPickerViewModel(
                context: context,
                selectedLineWorth: selectedLineWorth,
                selectedSnowLevel: selectedSnowLevel
            )
        )
        self.onPick = onPick
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Snow Level")) {
                    Picker("Snow Level", selection: $viewModel.selectedSnowLevel) {
                        ForEach(SnowLevel.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Section(header: Text("Selected Line")) {
                    if let selected = viewModel.selectedLineWorth {
                        LineRow(line: selected, isSelected: true)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.clearSelection()
                            }
                    } else {
                        Text("None Selected")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Available Lines")) {
                    ForEach(viewModel.allLineWorths, id: \.id) { line in
                        LineRow(line: line, isSelected: line == viewModel.selectedLineWorth)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.select(line)
                            }
                    }
                }

                Section(header: Text("Snow Level")) {
                    HStack {
                        ForEach(SnowLevel.allCases, id: \.self) { level in
                            Button(action: {
                                viewModel.selectedSnowLevel = level
                            }) {
                                VStack {
                                    Image(systemName: iconName(for: level))
                                        .font(.title2)
                                    Text(level.rawValue.capitalized)
                                        .font(.caption)
                                }
                                .padding()
                                .background(viewModel.selectedSnowLevel == level ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                if viewModel.selectedLineWorth != nil {
                    Section {
                        Button("Confirm Selection") {
                            if let selectedLine = viewModel.selectedLineWorth {
                                onPick(selectedLine, viewModel.selectedSnowLevel)
                                dismiss()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Select Line")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        viewModel.clearSelection()
                    }
                }
            }
        }
    }

    private func iconName(for level: SnowLevel) -> String {
        switch level {
        case .low: return "snowflake.circle"
        case .medium: return "snowflake"
        case .high: return "snowflake.circle.fill"
        }
    }
}

private struct LineRow: View {
    let line: LineWorth
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(line.name)
                    .font(.headline)
                Text(line.area)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
    }
}

#Preview {
    LineWorthPickerView(
        context: PersistenceController.preview.container.viewContext,
        onPick: { _, _ in }
    )
}
