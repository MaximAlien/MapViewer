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

    @State
    var showStatePeaks = false

    @Namespace
    var mapScope

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapReader { mapReader in
                Map(
                    position: $position,
                    selection: $selection,
                    scope: mapScope
                ) {
                    if showStatePeaks {
                        ForEach(StatePeak.all) { peak in
                            Marker("\(peak.name) (\(peak.elevationMeters) m)", coordinate: peak.coordinate)
                        }
                    }

                    ForEach(trails, id: \.id) { trail in
                        MapPolyline(coordinates: trail.coordinates)
                            .stroke(trail.isSelected ? .green.opacity(1.0) : .blue.opacity(1.0), lineWidth: 3)
                            .foregroundStyle(.purple.opacity(0.7))

                        if let trailhead = trail.coordinates.first {
                            Marker(coordinate: trailhead) {
                                VStack {
                                    if let trailRanking = trail.ranking {
                                        Text("\(trailRanking). \(trail.name)")
                                            .font(.caption)
                                    } else {
                                        Text(trail.name)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton(scope: mapScope)
                        .buttonBorderShape(.capsule)

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
                                    let parser = GPXParser()
                                    parser.parse(from: data)
                                    newTrails.append(
                                        Trail(
                                            name: url.lastPathComponent.replacing(".gpx", with: ""),
                                            coordinates: parser.coordinates,
                                            ranking: parser.ranking
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

                        let latitudes = trails.flatMap({ $0.coordinates }).map({ $0.latitude })
                        let longitudes = trails.flatMap({ $0.coordinates }).map({ $0.longitude })

                        let north = latitudes.max()!
                        let south = latitudes.min()!
                        let west = longitudes.min()!
                        let east = longitudes.max()!

                        let northWest = CLLocationCoordinate2D(latitude: north, longitude: west)
                        let southEast = CLLocationCoordinate2D(latitude: south, longitude: east)

                        let centerCoordinate = CLLocationCoordinate2D(
                            latitude: (northWest.latitude + southEast.latitude) / 2,
                            longitude: (northWest.longitude + southEast.longitude) / 2
                        )

                        let latitudeDelta = north - south
                        let longitudeDelta = east - west

                        position = .region(
                            MKCoordinateRegion(
                                center: centerCoordinate,
                                span: MKCoordinateSpan(
                                    latitudeDelta: latitudeDelta + 0.1,
                                    longitudeDelta: longitudeDelta + 0.1
                                )
                            )
                        )
                    case .failure(let error):
                        shouldShowAlert = true
                        alertMessage = error.localizedDescription
                    }
                }
                .onTapGesture(perform: { screenCoordinate in
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
                                isSelected: trail.id == trailsSortedByClosestDistanceToTap.first?.id,
                                ranking: trail.ranking
                            )
                        )
                    }

                    newTrails = newTrails.sorted(by: { !($0.isSelected && !$1.isSelected) })

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

                    currentTapCoordinate = tapLocation
                    trails = newTrails

                    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackGenerator.impactOccurred()
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

                Button(
                    showStatePeaks ? "Hide State Peaks" : "Show State Peaks",
                    systemImage: showStatePeaks ? "mountain.2" : "mountain.2.fill"
                ) {
                    showStatePeaks.toggle()
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

                    Task {
                        try await Task.sleep(for: .seconds(0.1))

                        let latitudes = trails.flatMap({ $0.coordinates }).map({ $0.latitude })
                        let longitudes = trails.flatMap({ $0.coordinates }).map({ $0.longitude })

                        let south = latitudes.min()!
                        let north = latitudes.max()!
                        let west = longitudes.min()!
                        let east = longitudes.max()!

                        let northWest = CLLocationCoordinate2D(latitude: north, longitude: west)
                        let southEast = CLLocationCoordinate2D(latitude: south, longitude: east)

                        let centerCoordinate = CLLocationCoordinate2D(
                            latitude: (northWest.latitude + southEast.latitude) / 2,
                            longitude: (northWest.longitude + southEast.longitude) / 2
                        )

                        let latitudeDelta = north - south
                        let longitudeDelta = east - west

                        position = .region(
                            MKCoordinateRegion(
                                center: centerCoordinate,
                                span: MKCoordinateSpan(
                                    latitudeDelta: latitudeDelta + 0.1,
                                    longitudeDelta: longitudeDelta + 0.1
                                )
                            )
                        )
                    }
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
        .sensoryFeedback(.increase, trigger: alertMessage)
    }
}

#Preview {
    ContentView()
}
