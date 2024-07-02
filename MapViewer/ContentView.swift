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
    var coordinates: [[CLLocationCoordinate2D]] = []

    @State
    var shouldShowfileImporter = false

    @State
    var shouldShowAlert = false

    @State
    var alertMessage: String = ""

    @State
    private var selection: Int?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapReader { mapReader in
                Map(
                    position: $position,
                    selection: $selection
                ) {
                    //            ForEach(GPXParser().polylines(for: [
                    //                "Bristlecone Pine Glacier Trail"
                    //            ]), id:\.self) { coordinates in
                    //                MapPolyline(coordinates: coordinates)
                    //                    .stroke(.blue.opacity(1.0), lineWidth: 3)
                    //                    .foregroundStyle(.purple.opacity(0.7))
                    //            }

                    ForEach(coordinates, id:\.self) { coordinates in
                        MapPolyline(coordinates: coordinates)
                            .stroke(.blue.opacity(1.0), lineWidth: 3)
                            .foregroundStyle(.purple.opacity(0.7))
                            .tag(1)

//                        Marker(coordinate: coordinates.first!) {
//                            Image(systemName: "mappin")
//                        }
//                        .tag(1)
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
                        var newCoordinates: [[CLLocationCoordinate2D]] = []
                        var dataArray: [Data] = []
                        urls.forEach { url in
                            do {
                                if url.startAccessingSecurityScopedResource() {
                                    let data = try Data(contentsOf: url, options: .alwaysMapped)
                                    newCoordinates.append(GPXParser().polyline(from: data))

                                    dataArray.append(data)
                                }
                            } catch {
                                shouldShowAlert = true
                                alertMessage = error.localizedDescription
                            }
                        }

                        UserDefaults.standard.setValue(dataArray, forKey: UserDefaults.coordinatesKey)
                        coordinates = newCoordinates

                        break
                    case .failure(let error):
                        shouldShowAlert = true
                        alertMessage = error.localizedDescription
                    }
                }
//                .onTapGesture(perform: { screenCoordinate in
//                    let tapLocation = mapReader.convert(screenCoordinate, from: .local)
//                    print(tapLocation)
//                })
//                .onChange(of: selection) {
//                    print("selection changed:", selection)
//                }
            }

            Menu {
                Button("Remove all", systemImage: "trash") {
                    UserDefaults.standard.setValue(nil, forKey: UserDefaults.coordinatesKey)
                    UserDefaults.standard.synchronize()
                    coordinates = []
                }
                .disabled(UserDefaults.standard.object(forKey: UserDefaults.coordinatesKey) == nil)

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
            if let savedCoordinates = UserDefaults.standard.object(forKey: UserDefaults.coordinatesKey) as? [Data] {
                savedCoordinates.forEach { data in
                    coordinates.append(GPXParser().polyline(from: data))
                }
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
