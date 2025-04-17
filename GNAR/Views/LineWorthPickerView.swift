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
    
    init(
        context: NSManagedObjectContext,
        selectedLine: Binding<LineWorth?>,
        selectedSnowLevel: Binding<SnowLevel>
    ) {
        _viewModel = StateObject(
            wrappedValue: LineWorthPickerViewModel(
                context: context,
                selectedLine: selectedLine.wrappedValue,
                selectedSnowLevel: selectedSnowLevel.wrappedValue
            )
        )
        _selectedLine = selectedLine
        _selectedSnowLevel = selectedSnowLevel
    }
    
    @Binding private var selectedLine: LineWorth?
    @Binding private var selectedSnowLevel: SnowLevel
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Snow Level Picker (Icon Buttons)
                Section(header: Text("Snow Level")) {
                    HStack {
                        ForEach(SnowLevel.allCases, id: \.self) { level in
                            Button(action: {
                                selectedSnowLevel = level
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
                                .background(selectedSnowLevel == level ? color(for: level).opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("snow-level-\(level.rawValue)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // MARK: - Display the currently selected line
                Section(header: Text("Selected Line")) {
                    if let line = selectedLine {
                        LineRow(
                            line: line,
                            selectedSnowLevel: selectedSnowLevel,
                            isSelected: false
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedLine = nil
                        }
                    } else {
                        Text("Select Line Below")
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - List of Available Lines
                SectionedList(viewModel: viewModel, selectedLine: $selectedLine, selectedSnowLevel: $selectedSnowLevel)
            }
            .navigationTitle("Select a Line")
            .accessibilityIdentifier("LineWorthPickerView")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if selectedLine != nil {
                        Button("Add") {
                            dismiss()
                        }
                        .accessibilityIdentifier("AddLineButton")
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
        level.displayColor
    }
    
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
    
    private struct SectionedList: View {
        @ObservedObject var viewModel: LineWorthPickerViewModel
        @Binding var selectedLine: LineWorth?
        @Binding var selectedSnowLevel: SnowLevel
        
        private struct AreaGroup: Identifiable {
            let id: String
            let area: String
            let lines: [LineWorth]
        }

        private var groupedLines: [AreaGroup] {
            let grouped = Dictionary(grouping: viewModel.lines) { $0.area }

            let sortedAreas = grouped.map { (area, lines) in
                let sortedLines = lines.sorted {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
                return AreaGroup(id: area, area: area, lines: sortedLines)
            }

            return sortedAreas.sorted {
                $0.area.localizedCaseInsensitiveCompare($1.area) == .orderedAscending
            }
        }

        var body: some View {
            ForEach(groupedLines) { group in
                Section(header: Text(group.area)) {
                    ForEach(group.lines, id: \.id) { line in
                        LineRow(
                            line: line,
                            selectedSnowLevel: selectedSnowLevel,
                            isSelected: line == selectedLine
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedLine = line
                        }
                        .accessibilityIdentifier("line-cell-\(line.name.replacingOccurrences(of: " ", with: "-").lowercased())")
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LineWorthPickerView(
        context: CoreDataStack.preview.viewContext,
        selectedLine: .constant(nil),
        selectedSnowLevel: .constant(.medium)
    )
}
