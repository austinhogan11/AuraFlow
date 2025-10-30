//
//  Track.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//
/*
 Purpose: Container for an entire run.
 What it does:
     •    points: [TrackPoint]
     •    duration: time between first and last timestamp.
     •    distance: total distance from the last point’s distanceFromStart.
     •    averagePaceSecondsPerMile: derived as duration / miles (1 mile = 1609.34 m).
 */
import Foundation

struct Track {
    var points: [TrackPoint]

    var duration: TimeInterval {
        guard let first = points.first?.timestamp, let last = points.last?.timestamp else { return 0 }
        return last.timeIntervalSince(first)
    }

    var distance: Double { points.last?.distanceFromStart ?? 0 } // meters

    // Pace as seconds per mile
    var averagePaceSecondsPerMile: Double {
        let miles = distance / 1609.34
        guard miles > 0 else { return 0 }
        return duration / miles
    }
}
