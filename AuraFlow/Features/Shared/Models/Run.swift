//
//  Run.swift
//  AuraFlow
//
//  Updated by ChatGPT on 10/30/25
//

import CoreLocation
import Foundation

/// Lightweight snapshot of a run for listing & persistence.
/// NOTE: Avoids CoreLocation types to keep Codable/Equatable trivial.
struct Run: Identifiable, Codable, Equatable {
    var id: UUID = .init()
    var importedAt: Date = .now

    // Display
    var title: String? // e.g. "Today, 11:06 AM"
    var location: String? // e.g. "Kennesaw, GA"

    // Metrics
    var distanceMeters: Double
    var durationSeconds: Double
    var avgPaceSecPerMile: Double

    /// GPX preview path stored as [[lat, lon]] to keep it Codable without CoreLocation.
    var previewPoints: [[Double]]

    // MARK: - Factory

    /// Build a snapshot from a parsed `Track`.
    static func from(track: Track, title: String?, location: String?) -> Run {
        let pts: [[Double]] = track.points.map { [$0.coord.latitude, $0.coord.longitude] }
        return Run(
            title: title,
            location: location,
            distanceMeters: track.distance,
            durationSeconds: track.duration,
            avgPaceSecPerMile: track.averagePaceSecondsPerMile,
            previewPoints: pts
        )
    }
}
