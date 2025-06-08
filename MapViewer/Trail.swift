//
//  Trail.swift
//  MapViewer
//
//  Created by Maxim Makhun on 7/2/24.
//

import CoreLocation
import Foundation

struct Trail: Identifiable, Codable {

    var id = UUID()

    let name: String

    let coordinates: [CLLocationCoordinate2D]

    let isSelected: Bool

    let ranking: Int?

    init(
        id: UUID = UUID(),
        name: String,
        coordinates: [CLLocationCoordinate2D],
        isSelected: Bool = false,
        ranking: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.coordinates = coordinates
        self.isSelected = isSelected
        self.ranking = ranking
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(id)
        try container.encode(name)
        try container.encode(coordinates)
        try container.encode(isSelected)
        try container.encode(ranking)
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        id = try container.decode(UUID.self)
        name = try container.decode(String.self)
        coordinates = try container.decode([CLLocationCoordinate2D].self)
        isSelected = try container.decode(Bool.self)
        ranking = try container.decodeIfPresent(Int.self)
    }
}
