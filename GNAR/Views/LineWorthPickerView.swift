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

    let onPick: (LineWorth, SnowLevel) -> Void // Callback with selected line and snow level

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
                // MARK: - Snow Level Picker (Icon Buttons)
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

                // MARK: - Display the currently selected line
                Section(header: Text("Selected Line")) {
                    if let selected = viewModel.selectedLineWorth {
                        LineRow(line: selected, isSelected: true)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.clearSelection()
                            }
                    } else {
                        Text("Select Line Below")
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: - List of Available Lines
                Section(header: Text("Available Lines")) {
                    ForEach(viewModel.allLineWorths, id: \.id) { line in
                        LineRow(line: line, isSelected: line == viewModel.selectedLineWorth)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.select(line)
                            }
                    }
                }
            }
            .navigationTitle("Select Line")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.selectedLineWorth != nil {
                        Button("Add") {
                            if let selectedLine = viewModel.selectedLineWorth {
                                onPick(selectedLine, viewModel.selectedSnowLevel) // Return selection via callback
                                dismiss() // Dismiss the sheet
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Icon Mapping for Snow Levels
    private func iconName(for level: SnowLevel) -> String {
        switch level {
        case .low: return "snowflake.circle"
        case .medium: return "snowflake"
        case .high: return "snowflake.circle.fill"
        }
    }
}

// MARK: - Line Row UI Component
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

// MARK: - Preview
#Preview {
    LineWorthPickerView(
        context: PersistenceController.preview.container.viewContext,
        onPick: { _, _ in }
    )
}
