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

struct TrackPoint: Hashable, Equatable {
    let coord: CLLocationCoordinate2D
    let elevation: Double?
    let timestamp: Date

    // Derived (mutable) fields
    var distanceFromStart: Double = 0
    var speedMps: Double = 0

    // MARK: - Hashable / Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(coord.latitude)
        hasher.combine(coord.longitude)
        hasher.combine(timestamp.timeIntervalSince1970)
    }

    static func == (lhs: TrackPoint, rhs: TrackPoint) -> Bool {
        lhs.coord.latitude == rhs.coord.latitude &&
            lhs.coord.longitude == rhs.coord.longitude &&
            lhs.timestamp == rhs.timestamp
    }
}
