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
                                        .foregroundColor(color(for: level))
                                    Text(level.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundColor(color(for: level))
                                }
                                .padding()
                                .background(viewModel.selectedSnowLevel == level ? color(for: level).opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // MARK: - Display the currently selected line
                Section(header: Text("Selected Line")) {
                    if let line = viewModel.selectedLineWorth {
                        LineRow(
                            line: line,
                            selectedSnowLevel: viewModel.selectedSnowLevel,
                            isSelected: false
                        )
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
                SectionedList(viewModel: viewModel)
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
    
    private func color(for level: SnowLevel) -> Color {
        switch level {
        case .low: return level.displayColor
        case .medium: return level.displayColor
        case .high: return level.displayColor
        }
    }
    
    private struct SectionedList: View {
        @ObservedObject var viewModel: LineWorthPickerViewModel

        var groupedLines: [(area: String, lines: [LineWorth])] {
            let grouped = Dictionary(grouping: viewModel.allLineWorths) { $0.area }

            let sortedAreas = grouped.map { (area, lines) in
                let sortedLines = lines.sorted {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
                return (area: area, lines: sortedLines)
            }

            return sortedAreas.sorted {
                $0.area.localizedCaseInsensitiveCompare($1.area) == .orderedAscending
            }
        }

        var body: some View {
            ForEach(groupedLines, id: \.area) { (area, lines) in
                Section(header: Text(area)) {
                    ForEach(lines, id: \.id) { line in
                        LineRow(
                            line: line,
                            selectedSnowLevel: viewModel.selectedSnowLevel,
                            isSelected: line == viewModel.selectedLineWorth
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.select(line)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Line Row UI Component
private struct LineRow: View {
    let line: LineWorth
    let selectedSnowLevel: SnowLevel
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(line.name)
                    .font(.headline)

                Spacer()

                Text("\(points(for: selectedSnowLevel)) pts")
                    .font(.title3.bold())
            }

            HStack(spacing: 12) {
                ForEach(SnowLevel.allCases, id: \.self) { level in
                    let value = points(for: level)
                    Text("\(value)")
                        .font(.caption)
                        .foregroundColor(level == selectedSnowLevel ? .white : level.displayColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(level == selectedSnowLevel ? level.displayColor : level.displayColor.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
        )
    }

    private func points(for level: SnowLevel) -> Int {
        switch level {
        case .low: return line.basePointsLow?.intValue ?? 0
        case .medium: return line.basePointsMedium?.intValue ?? 0
        case .high: return line.basePointsHigh?.intValue ?? 0
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
