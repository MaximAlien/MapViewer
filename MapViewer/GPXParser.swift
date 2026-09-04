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

    var coordinates = [CLLocationCoordinate2D]()

    var elevations = [Double]()

    var ranking: Int?

    private var currentElement: String = ""
    private var currentElevationString: String = ""
    private var isInTrackPoint = false

    func polylines(for fileNames: [String]) -> [[CLLocationCoordinate2D]] {
        var allCoordinates: [[CLLocationCoordinate2D]] = []

        for fileName in fileNames {
            coordinates.removeAll()
            elevations.removeAll()

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

    func parse(from data: Data) {
        coordinates.removeAll()
        elevations.removeAll()
        ranking = nil
        currentElement = ""
        currentElevationString = ""
        isInTrackPoint = false

        let parser = XMLParser(data: data)
        parser.delegate = self

        if !parser.parse() {
            print("Failed to parse")
        }
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName

        if elementName == "ranking", let value = attributeDict["value"] {
            ranking = Int(value)
        }
        if elementName == "trkpt" /* || elementName == "wpt" */ {
            isInTrackPoint = true
            currentElevationString = ""
            let latitude = CLLocationDegrees(attributeDict["lat"]!)!
            let longitude = CLLocationDegrees(attributeDict["lon"]!)!

            coordinates.append(CLLocationCoordinate2DMake(latitude, longitude))
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "trkpt" {
            let elevation = Double(currentElevationString.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            elevations.append(elevation)
            isInTrackPoint = false
            currentElevationString = ""
        }
        currentElement = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "ele" && isInTrackPoint {
            currentElevationString += string
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
