//
//  GPXParser.swift
//  MapViewer
//
//  Created by Maxim Makhun on 11/9/23.
//

import Foundation
import MapKit
import SwiftUI

class GPXParser: NSObject, XMLParserDelegate {

    private var coordinates = [CLLocationCoordinate2D]()

    func polylines(for fileNames: [String]) -> [[CLLocationCoordinate2D]] {
        var allCoordinates: [[CLLocationCoordinate2D]] = []

        for fileName in fileNames {
            coordinates.removeAll()

            guard let filePath = Bundle.main.path(forResource: fileName, ofType: "gpx") else {
                continue
            }

            let data = NSData(contentsOfFile: filePath)
            let parser = XMLParser(data: data! as Data)
            parser.delegate = self

            if !parser.parse() {
                print("Failed to parse: \(fileName)")
            }

            allCoordinates.append(coordinates)
        }

        return allCoordinates
    }

    func polyline(from data: Data) -> [CLLocationCoordinate2D] {
        coordinates.removeAll()

        let parser = XMLParser(data: data)
        parser.delegate = self

        if !parser.parse() {
            print("Failed to parse")
        }

        return coordinates
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        if elementName == "trkpt" /* || elementName == "wpt" */ {
            let latitude = CLLocationDegrees(attributeDict["lat"]!)!
            let longitude = CLLocationDegrees(attributeDict["lon"]!)!

            coordinates.append(CLLocationCoordinate2DMake(latitude, longitude))
        }
    }
}

extension CLLocationCoordinate2D: @retroactive Hashable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
