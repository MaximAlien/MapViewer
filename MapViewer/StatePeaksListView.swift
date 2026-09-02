//
//  StatePeaksListView.swift
//  MapViewer
//
//  Created by Maxim Makhun on 8/27/26.
//

import SwiftUI

struct StatePeaksListView: View {

    @ObservedObject var store: PeaksStore

    @Binding var showOnMap: Bool

    @State private var searchText = ""

    @Environment(\.dismiss) private var dismiss

    private var filtered: [StatePeak] {
        guard !searchText.isEmpty else { return store.peaks }
        return store.peaks.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.state.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var climbed: Int  { store.peaks.filter { $0.status == .climbed }.count }
    private var attempted: Int { store.peaks.filter { $0.status == .attempted }.count }
    private var remaining: Int { store.peaks.count - climbed - attempted }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 0) {
                        statCell(count: climbed,  label: "Climbed",   color: .green)
                        Divider()
                        statCell(count: attempted, label: "Attempted", color: .orange)
                        Divider()
                        statCell(count: remaining, label: "Remaining", color: .gray)
                    }
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    ForEach(filtered) { peak in
                        peakRow(peak)
                    }
                }
            }
            .listSectionSpacing(10)
            .searchable(text: $searchText, prompt: "Search by name or state")
            .navigationTitle("Highest State Peaks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Toggle(isOn: $showOnMap) {
                        Label("Show on Map", systemImage: "map")
                    }
                    .toggleStyle(.button)
                    .tint(.accentColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func statCell(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func peakRow(_ peak: StatePeak) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(peak.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text("\(peak.state) · \(peak.elevationMeters) m")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Menu {
                ForEach(ClimbStatus.allCases, id: \.self) { status in
                    Button {
                        store.setStatus(status, for: peak)
                    } label: {
                        if peak.status == status {
                            Label(status.label, systemImage: "checkmark")
                        } else {
                            Text(status.label)
                        }
                    }
                }
            } label: {
                statusBadge(peak.status)
            }
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private func statusBadge(_ status: ClimbStatus) -> some View {
        switch status {
        case .none:
            Text("Set Status")
                .font(.caption)
                .fontWeight(.medium)
        case .attempted:
            Text("🟡 Attempted")
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.12))
                .foregroundStyle(.orange)
                .clipShape(Capsule())
        case .climbed:
            Text("🟢 Climbed")
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.12))
                .foregroundStyle(.green)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    StatePeaksListView(store: PeaksStore(), showOnMap: .constant(false))
}
