//
//  PostProcess.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//
/*
 Purpose: Compute distance and speed from raw points.
 What it does:
     •    Iterates consecutive points:
     •    Uses CLLocation.distance(from:) for segment meters.
     •    Accumulates to distanceFromStart.
     •    Calculates instantaneous speedMps = deltaDistance / deltaTime.
     •    Clamps unrealistic spikes (0…8 m/s) as a simple outlier guard.
     •    Initializes the first point’s derived values to zero.
 */
import CoreLocation
import Foundation

enum TrackPostProcess {
    /// Computes cumulative distance and instantaneous speed; clamps spikes.
    static func fillDistanceAndSpeed(points: inout [TrackPoint]) {
        guard points.count > 1 else {
            if !points.isEmpty { points[0].distanceFromStart = 0; points[0].speedMps = 0 }
            return
        }
        var total: Double = 0
        for i in 1 ..< points.count {
            let a = CLLocation(latitude: points[i - 1].coord.latitude, longitude: points[i - 1].coord.longitude)
            let b = CLLocation(latitude: points[i].coord.latitude, longitude: points[i].coord.longitude)
            let d = b.distance(from: a) // meters
            total += d
            let dt = points[i].timestamp.timeIntervalSince(points[i - 1].timestamp)
            points[i].distanceFromStart = total
            points[i].speedMps = (dt > 0) ? min(max(d / dt, 0), 8.0) : 0 // 0..8 m/s clamp
        }
        points[0].distanceFromStart = 0
        points[0].speedMps = 0
    }
}
