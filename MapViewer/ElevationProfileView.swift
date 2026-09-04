//
//  ElevationProfileView.swift
//  MapViewer
//
//  Created by Maxim Makhun on 9/1/26.
//

import Charts
import CoreLocation
import SwiftUI

struct ElevationDataPoint: Identifiable {
    let id = UUID()
    let distance: Double
    let elevation: Double
}

struct ElevationProfileView: View {

    let trail: Trail

    @Environment(\.dismiss) private var dismiss

    private var dataPoints: [ElevationDataPoint] {
        guard !trail.elevations.isEmpty,
              trail.elevations.count == trail.coordinates.count else {
            return []
        }

        var cumulative: [Double] = [0]
        for i in 1..<trail.coordinates.count {
            let prev = trail.coordinates[i - 1]
            let curr = trail.coordinates[i]
            let d = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
                .distance(from: CLLocation(latitude: curr.latitude, longitude: curr.longitude))
            cumulative.append(cumulative[i - 1] + d)
        }

        let targetCount = min(trail.coordinates.count, 300)
        let step = max(1, trail.coordinates.count / targetCount)
        var indices = Array(stride(from: 0, to: trail.coordinates.count, by: step))
        if indices.last != trail.coordinates.count - 1 {
            indices.append(trail.coordinates.count - 1)
        }

        return indices.map { i in
            ElevationDataPoint(distance: cumulative[i] / 1000.0, elevation: trail.elevations[i])
        }
    }

    private var minElevation: Double {
        dataPoints.map(\.elevation).min() ?? 0
    }

    private var maxElevation: Double {
        dataPoints.map(\.elevation).max() ?? 0
    }

    private var elevationGain: Double {
        guard trail.elevations.count >= 2 else { return 0 }
        var gain: Double = 0
        for i in 1..<trail.elevations.count {
            let diff = trail.elevations[i] - trail.elevations[i - 1]
            if diff > 0 { gain += diff }
        }
        return gain
    }

    private var totalDistance: Double {
        dataPoints.last?.distance ?? 0
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if dataPoints.isEmpty {
                    Text("No elevation data available.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    HStack(spacing: 0) {
                        ElevationStat(label: "Distance", value: String(format: "%.1f km", totalDistance))
                        Divider().frame(height: 32)
                        ElevationStat(label: "Min", value: String(format: "%.0f m", minElevation))
                        Divider().frame(height: 32)
                        ElevationStat(label: "Max", value: String(format: "%.0f m", maxElevation))
                        Divider().frame(height: 32)
                        ElevationStat(label: "Gain", value: String(format: "+%.0f m", elevationGain))
                    }
                    .padding(.horizontal)

                    let yMin = minElevation - (maxElevation - minElevation) * 0.1
                    let yMax = maxElevation + (maxElevation - minElevation) * 0.1

                    Chart(dataPoints) { point in
                        AreaMark(
                            x: .value("Distance (km)", point.distance),
                            yStart: .value("Base", yMin),
                            yEnd: .value("Elevation (m)", point.elevation)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green.opacity(0.5), .green.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Distance (km)", point.distance),
                            y: .value("Elevation (m)", point.elevation)
                        )
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                    }
                    .chartXAxisLabel("Distance (km)", alignment: .center)
                    .chartYAxisLabel("Elevation (m)")
                    .chartXScale(domain: 0...totalDistance)
                    .chartYScale(domain: yMin...yMax)
                    .padding(.horizontal)
                    .frame(height: 180)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
            .padding(.vertical)
            .navigationTitle(trail.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct ElevationStat: View {

    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
}
