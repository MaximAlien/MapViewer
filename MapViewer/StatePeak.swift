//
//  StatePeak.swift
//  MapViewer
//

import CoreLocation
import Foundation

struct StatePeak: Identifiable {

    let id = UUID()

    let state: String

    let name: String

    let elevationMeters: Int

    let coordinate: CLLocationCoordinate2D

    static let all: [StatePeak] = [
        StatePeak(state: "Alabama",        name: "Cheaha Mountain",   elevationMeters: 734,  coordinate: CLLocationCoordinate2D(latitude: 33.4857, longitude: -85.8060)),
        StatePeak(state: "Alaska",         name: "Denali",            elevationMeters: 6194, coordinate: CLLocationCoordinate2D(latitude: 63.0695, longitude: -151.0074)),
        StatePeak(state: "Arizona",        name: "Humphreys Peak",    elevationMeters: 3851, coordinate: CLLocationCoordinate2D(latitude: 35.3464, longitude: -111.6780)),
        StatePeak(state: "Arkansas",       name: "Magazine Mountain", elevationMeters: 839,  coordinate: CLLocationCoordinate2D(latitude: 35.1670, longitude: -93.6446)),
        StatePeak(state: "California",     name: "Mt. Whitney",       elevationMeters: 4421, coordinate: CLLocationCoordinate2D(latitude: 36.5785, longitude: -118.2923)),
        StatePeak(state: "Colorado",       name: "Mt. Elbert",        elevationMeters: 4399, coordinate: CLLocationCoordinate2D(latitude: 39.1178, longitude: -106.4453)),
        StatePeak(state: "Connecticut",    name: "Bear Mountain",     elevationMeters: 725,  coordinate: CLLocationCoordinate2D(latitude: 42.0012, longitude: -73.4457)),
        StatePeak(state: "Delaware",       name: "Ebright Azimuth",   elevationMeters: 137,  coordinate: CLLocationCoordinate2D(latitude: 39.8368, longitude: -75.5188)),
        StatePeak(state: "Florida",        name: "Britton Hill",      elevationMeters: 105,  coordinate: CLLocationCoordinate2D(latitude: 30.9038, longitude: -86.2816)),
        StatePeak(state: "Georgia",        name: "Brasstown Bald",    elevationMeters: 1458, coordinate: CLLocationCoordinate2D(latitude: 34.8742, longitude: -83.8121)),
        StatePeak(state: "Hawaii",         name: "Mauna Kea",         elevationMeters: 4205, coordinate: CLLocationCoordinate2D(latitude: 19.8207, longitude: -155.4680)),
        StatePeak(state: "Idaho",          name: "Borah Peak",        elevationMeters: 3859, coordinate: CLLocationCoordinate2D(latitude: 44.1374, longitude: -113.7811)),
        StatePeak(state: "Illinois",       name: "Charles Mound",     elevationMeters: 376,  coordinate: CLLocationCoordinate2D(latitude: 42.5003, longitude: -90.2401)),
        StatePeak(state: "Indiana",        name: "Hoosier Hill",      elevationMeters: 383,  coordinate: CLLocationCoordinate2D(latitude: 40.0020, longitude: -84.8549)),
        StatePeak(state: "Iowa",           name: "Hawkeye Point",     elevationMeters: 509,  coordinate: CLLocationCoordinate2D(latitude: 43.4603, longitude: -95.7077)),
        StatePeak(state: "Kansas",         name: "Mt. Sunflower",     elevationMeters: 1231, coordinate: CLLocationCoordinate2D(latitude: 39.0222, longitude: -102.0377)),
        StatePeak(state: "Kentucky",       name: "Black Mountain",    elevationMeters: 1263, coordinate: CLLocationCoordinate2D(latitude: 36.9142, longitude: -82.8938)),
        StatePeak(state: "Louisiana",      name: "Driskill Mountain", elevationMeters: 163,  coordinate: CLLocationCoordinate2D(latitude: 32.4243, longitude: -92.9001)),
        StatePeak(state: "Maine",          name: "Katahdin",          elevationMeters: 1606, coordinate: CLLocationCoordinate2D(latitude: 45.9044, longitude: -68.9213)),
        StatePeak(state: "Maryland",       name: "Hoye-Crest",        elevationMeters: 1024, coordinate: CLLocationCoordinate2D(latitude: 39.2381, longitude: -79.4869)),
        StatePeak(state: "Massachusetts",  name: "Mt. Greylock",      elevationMeters: 1064, coordinate: CLLocationCoordinate2D(latitude: 42.6376, longitude: -73.1662)),
        StatePeak(state: "Michigan",       name: "Mt. Arvon",         elevationMeters: 604,  coordinate: CLLocationCoordinate2D(latitude: 46.7558, longitude: -88.1552)),
        StatePeak(state: "Minnesota",      name: "Eagle Mountain",    elevationMeters: 701,  coordinate: CLLocationCoordinate2D(latitude: 47.8977, longitude: -90.5605)),
        StatePeak(state: "Mississippi",    name: "Woodall Mountain",  elevationMeters: 246,  coordinate: CLLocationCoordinate2D(latitude: 34.7876, longitude: -88.2415)),
        StatePeak(state: "Missouri",       name: "Taum Sauk Mountain",elevationMeters: 540,  coordinate: CLLocationCoordinate2D(latitude: 37.5706, longitude: -90.7274)),
        StatePeak(state: "Montana",        name: "Granite Peak",      elevationMeters: 3904, coordinate: CLLocationCoordinate2D(latitude: 45.1634, longitude: -109.8076)),
        StatePeak(state: "Nebraska",       name: "Panorama Point",    elevationMeters: 1653, coordinate: CLLocationCoordinate2D(latitude: 41.0069, longitude: -104.0306)),
        StatePeak(state: "Nevada",         name: "Wheeler Peak",      elevationMeters: 3982, coordinate: CLLocationCoordinate2D(latitude: 38.9858, longitude: -114.3138)),
        StatePeak(state: "New Hampshire",  name: "Mt. Washington",    elevationMeters: 1917, coordinate: CLLocationCoordinate2D(latitude: 44.2705, longitude: -71.3033)),
        StatePeak(state: "New Jersey",     name: "High Point",        elevationMeters: 550,  coordinate: CLLocationCoordinate2D(latitude: 41.3205, longitude: -74.6638)),
        StatePeak(state: "New Mexico",     name: "Wheeler Peak",      elevationMeters: 4013, coordinate: CLLocationCoordinate2D(latitude: 36.5569, longitude: -105.4170)),
        StatePeak(state: "New York",       name: "Mt. Marcy",         elevationMeters: 1629, coordinate: CLLocationCoordinate2D(latitude: 44.1127, longitude: -73.9237)),
        StatePeak(state: "North Carolina", name: "Mt. Mitchell",      elevationMeters: 2037, coordinate: CLLocationCoordinate2D(latitude: 35.7649, longitude: -82.2651)),
        StatePeak(state: "North Dakota",   name: "White Butte",       elevationMeters: 1069, coordinate: CLLocationCoordinate2D(latitude: 46.3866, longitude: -103.3023)),
        StatePeak(state: "Ohio",           name: "Campbell Hill",     elevationMeters: 472,  coordinate: CLLocationCoordinate2D(latitude: 40.3675, longitude: -83.6993)),
        StatePeak(state: "Oklahoma",       name: "Black Mesa",        elevationMeters: 1516, coordinate: CLLocationCoordinate2D(latitude: 36.9317, longitude: -102.9979)),
        StatePeak(state: "Oregon",         name: "Mt. Hood",          elevationMeters: 3428, coordinate: CLLocationCoordinate2D(latitude: 45.3735, longitude: -121.6960)),
        StatePeak(state: "Pennsylvania",   name: "Mt. Davis",         elevationMeters: 979,  coordinate: CLLocationCoordinate2D(latitude: 39.7860, longitude: -79.1767)),
        StatePeak(state: "Rhode Island",   name: "Jerimoth Hill",     elevationMeters: 247,  coordinate: CLLocationCoordinate2D(latitude: 41.8510, longitude: -71.7784)),
        StatePeak(state: "South Carolina", name: "Sassafras Mountain",elevationMeters: 1085, coordinate: CLLocationCoordinate2D(latitude: 35.0646, longitude: -82.7773)),
        StatePeak(state: "South Dakota",   name: "Black Elk Peak",    elevationMeters: 2207, coordinate: CLLocationCoordinate2D(latitude: 43.8661, longitude: -103.5322)),
        StatePeak(state: "Tennessee",      name: "Clingmans Dome",    elevationMeters: 2025, coordinate: CLLocationCoordinate2D(latitude: 35.5629, longitude: -83.4986)),
        StatePeak(state: "Texas",          name: "Guadalupe Peak",    elevationMeters: 2667, coordinate: CLLocationCoordinate2D(latitude: 31.8912, longitude: -104.8606)),
        StatePeak(state: "Utah",           name: "Kings Peak",        elevationMeters: 4123, coordinate: CLLocationCoordinate2D(latitude: 40.7763, longitude: -110.3729)),
        StatePeak(state: "Vermont",        name: "Mt. Mansfield",     elevationMeters: 1339, coordinate: CLLocationCoordinate2D(latitude: 44.5437, longitude: -72.8143)),
        StatePeak(state: "Virginia",       name: "Mt. Rogers",        elevationMeters: 1746, coordinate: CLLocationCoordinate2D(latitude: 36.6598, longitude: -81.5447)),
        StatePeak(state: "Washington",     name: "Mt. Rainier",       elevationMeters: 4392, coordinate: CLLocationCoordinate2D(latitude: 46.8529, longitude: -121.7269)),
        StatePeak(state: "West Virginia",  name: "Spruce Knob",       elevationMeters: 1482, coordinate: CLLocationCoordinate2D(latitude: 38.7000, longitude: -79.5319)),
        StatePeak(state: "Wisconsin",      name: "Timms Hill",        elevationMeters: 595,  coordinate: CLLocationCoordinate2D(latitude: 45.4512, longitude: -90.1954)),
        StatePeak(state: "Wyoming",        name: "Gannett Peak",      elevationMeters: 4207, coordinate: CLLocationCoordinate2D(latitude: 43.1842, longitude: -109.6542)),
    ]
}
