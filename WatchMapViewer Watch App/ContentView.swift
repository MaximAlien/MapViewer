//
//  ContentView.swift
//  WatchMapViewer Watch App
//
//  Created by Maxim Makhun on 11/9/23.
//

import SwiftUI
import MapKit

struct ContentView: View {

    @State
    var position: MapCameraPosition = .userLocation(fallback: .automatic)

    @ObservedObject
    var locationManager = LocationManager()

    var body: some View {
        Map(
            position: $position
        ) {
            ForEach(GPXParser().polylines(for: [
                ""
            ]), id:\.self) { coordinates in
                MapPolyline(coordinates: coordinates)
                    .stroke(.purple.opacity(1.0), lineWidth: 3)
                    .foregroundStyle(.purple.opacity(0.7))
            }
        }
        .mapControls {
            MapUserLocationButton()
        }
        // .mapControlVisibility(.hidden)
    }
}

#Preview {
    ContentView()
}
