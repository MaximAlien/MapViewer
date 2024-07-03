//
//  ContentView.swift
//  MapViewer
//
//  Created by Maxim Makhun on 11/9/23.
//

import SwiftUI
import MapKit
import UniformTypeIdentifiers

extension UserDefaults {

    static let coordinatesKey = "com.map_viewer.coordinates"
}

struct ContentView: View {

    @State
    var position: MapCameraPosition = .userLocation(fallback: .automatic)

    @ObservedObject
    var locationManager = LocationManager()

    @State
    var trails: [Trail] = []

    @State
    var shouldShowfileImporter = false

    @State
    var shouldShowAlert = false

    @State
    var alertMessage: String = ""

    @State
    private var selection: Int?

    @State
    var currentTapCoordinate: CLLocationCoordinate2D? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapReader { mapReader in
                Map(
                    position: $position,
                    selection: $selection
                ) {
                    ForEach(trails, id: \.id) { trail in
                        MapPolyline(coordinates: trail.coordinates)
                            .stroke(trail.isSelected ? .green.opacity(1.0) : .blue.opacity(1.0), lineWidth: 3)
                            .foregroundStyle(.purple.opacity(0.7))
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                        .buttonBorderShape(.circle)

                    MapCompass()

                    MapScaleView(anchorEdge: .leading)
                }
                .mapStyle(.standard)
                // .controlSize(.mini)
                // .mapStyle(.imagery)
                // .mapControlVisibility(.hidden)
                .environment(\.colorScheme, .light)
                .fileImporter(
                    isPresented: $shouldShowfileImporter,
                    allowedContentTypes: [UTType(filenameExtension: "gpx")!],
                    allowsMultipleSelection: true
                ) { result in
                    switch result {
                    case .success(let urls):
                        var newTrails: [Trail] = []
                        urls.forEach { url in
                            do {
                                if url.startAccessingSecurityScopedResource() {
                                    let data = try Data(contentsOf: url, options: .alwaysMapped)
                                    newTrails.append(
                                        Trail(
                                            name: url.lastPathComponent.replacing(".gpx", with: ""),
                                            coordinates: GPXParser().polyline(
                                                from: data
                                            )
                                        )
                                    )
                                }
                            } catch {
                                shouldShowAlert = true
                                alertMessage = error.localizedDescription
                            }
                        }

                        do {
                            let newTrailsData = try JSONEncoder().encode(newTrails)
                            UserDefaults.standard.set(newTrailsData, forKey: UserDefaults.coordinatesKey)
                            trails = newTrails
                        } catch {
                            shouldShowAlert = true
                            alertMessage = error.localizedDescription
                        }

                        // TODO: Add camera change to fit all trails.
                    case .failure(let error):
                        shouldShowAlert = true
                        alertMessage = error.localizedDescription
                    }
                }
                .onTapGesture(perform: {
                    screenCoordinate in
                    guard let tapLocation = mapReader.convert(screenCoordinate, from: .local) else {
                        return
                    }

                    let trailsSortedByClosestDistanceToTap = trails.sorted(by: { firstTrail, secondTrail in
                        let firstTrailMinimumDistance = firstTrail.coordinates.map {
                            CLLocation(
                                latitude: $0.latitude,
                                longitude: $0.longitude
                            ).distance(
                                from: CLLocation(
                                    latitude: tapLocation.latitude,
                                    longitude: tapLocation.longitude
                                )
                            )
                        }.min() ?? .greatestFiniteMagnitude

                        let secondTrailMinimumDistance = secondTrail.coordinates.map {
                            CLLocation(
                                latitude: $0.latitude,
                                longitude: $0.longitude
                            ).distance(
                                from: CLLocation(
                                    latitude: tapLocation.latitude,
                                    longitude: tapLocation.longitude
                                )
                            )
                        }.min() ?? .greatestFiniteMagnitude

                        return firstTrailMinimumDistance < secondTrailMinimumDistance
                    })

                    var newTrails: [Trail] = []
                    for trail in trails {
                        newTrails.append(
                            Trail(
                                name: trail.name,
                                coordinates: trail.coordinates,
                                isSelected: trail.id == trailsSortedByClosestDistanceToTap.first?.id
                            )
                        )
                    }

                    guard let closestTrail = trailsSortedByClosestDistanceToTap.first else {
                        return
                    }

                    let minimumDistanceToClosestTrail = closestTrail.coordinates.map {
                        CLLocation(
                            latitude: $0.latitude,
                            longitude: $0.longitude
                        ).distance(
                            from: CLLocation(
                                latitude: tapLocation.latitude,
                                longitude: tapLocation.longitude
                            )
                        )
                    }.min() ?? .greatestFiniteMagnitude

                    if minimumDistanceToClosestTrail > 100.0 {
                        return
                    }

                    shouldShowAlert = true

                    let coordinatesOfClosestTrail = trailsSortedByClosestDistanceToTap.first?.coordinates ?? []
                    let closestTrailDistance = zip(coordinatesOfClosestTrail.dropFirst(), coordinatesOfClosestTrail).map { (c, d) in
                        let distance = CLLocation(
                            latitude: c.latitude,
                            longitude: c.longitude
                        ).distance(
                            from: CLLocation(
                                latitude: d.latitude,
                                longitude: d.longitude
                            )
                        )

                        return distance
                    }.reduce(0.0, +)

                    let formattedDistance = String(format: "%.2f", closestTrailDistance / 1000.0)
                    alertMessage = "Distance of \(closestTrail.name): \(formattedDistance) km"

                    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackGenerator.impactOccurred()

                    currentTapCoordinate = tapLocation
                    trails = newTrails
                })
                // .onChange(of: selection) {
                //     print("Selection changed: \(selection)")
                // }
            }

            Menu {
                Button("Remove all", systemImage: "trash") {
                    UserDefaults.standard.set(nil, forKey: UserDefaults.coordinatesKey)
                    UserDefaults.standard.synchronize()
                    trails = []
                }
                .disabled(UserDefaults.standard.data(forKey: UserDefaults.coordinatesKey) == nil)

                Button("Add GPX", systemImage: "point.topleft.down.to.point.bottomright.curvepath.fill") {
                    shouldShowfileImporter = true
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .renderingMode(.original)
                    .frame(width: 45.0, height: 45.0)
                    .background(.white)
                    .cornerRadius(22.5)
                    .padding(.trailing, 5.0)
                    .padding(.bottom, 5.0)
            }
        }
        .onAppear {
            do {
                if let trailsData = UserDefaults.standard.data(forKey: UserDefaults.coordinatesKey) {
                    trails = try JSONDecoder().decode([Trail].self, from: trailsData)
                } else {
                    print("Trails data not available")
                }
            } catch {
                shouldShowAlert = true
                alertMessage = error.localizedDescription
            }
        }
        .alert(alertMessage, isPresented: $shouldShowAlert) {
            Button("OK", role: .cancel) {

            }
        }
    }
}

#Preview {
    ContentView()
}
