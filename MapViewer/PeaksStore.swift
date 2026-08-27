//
//  PeaksStore.swift
//  MapViewer
//
//  Created by Maxim Makhun on 8/27/26.
//

import Foundation

class PeaksStore: ObservableObject {

    private static let userDefaultsKey = "com.map_viewer.peak_statuses"

    @Published private(set) var peaks: [StatePeak]

    init() {
        var allStatePeaks = StatePeak.all
        if let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
           let saved = try? JSONDecoder().decode([String: ClimbStatus].self, from: data) {
            allStatePeaks = allStatePeaks.map { peak in
                var peak = peak
                peak.status = saved[peak.state] ?? .none
                return peak
            }
        }
        peaks = allStatePeaks
    }

    func setStatus(_ status: ClimbStatus, for peak: StatePeak) {
        guard let index = peaks.firstIndex(where: { $0.state == peak.state }) else { return }
        peaks[index].status = status
        save()
    }

    private func save() {
        var dict: [String: ClimbStatus] = [:]
        for peak in peaks where peak.status != .none {
            dict[peak.state] = peak.status
        }
        if let data = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }
    }
}
