//
//  TrackPoint.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//
/*
 Purpose: Single sample in the GPS track.
 What it does:
     •    Stores coord (lat/lon), elevation?, and timestamp.
     •    Holds derived fields filled after parsing:
     •    distanceFromStart (meters)
     •    speedMps (meters/second)
     •    Adds Hashable conformance to CLLocationCoordinate2D so TrackPoint can be Hashable (useful for sets/diffs later).
 */
import CoreLocation
import Foundation

// Make coordinates Hashable so TrackPoint can be Hashable.
extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct TrackPoint: Hashable {
    let coord: CLLocationCoordinate2D
    let elevation: Double?
    let timestamp: Date

    // Filled after parsing
    var distanceFromStart: Double = 0 // meters
    var speedMps: Double = 0 // meters/second
}
