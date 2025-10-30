//
//  GeoProjector.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//

import CoreLocation
import SwiftUI

/// Projects geographic coordinates (lat/lon) into 2D view space,
/// preserving aspect ratio and adding uniform padding.
struct GeoProjector {
    private let minLat: Double
    private let maxLat: Double
    private let minLon: Double
    private let maxLon: Double
    private let paddingFrac: CGFloat   // e.g., 0.08 = 8% padding around the path

    init(points: [TrackPoint], padding: CGFloat = 0.08) {
        // Handle degenerate input
        guard !points.isEmpty else {
            self.minLat = 0; self.maxLat = 1
            self.minLon = 0; self.maxLon = 1
            self.paddingFrac = padding
            return
        }
        let lats = points.map { $0.coord.latitude }
        let lons = points.map { $0.coord.longitude }
        self.minLat = lats.min() ?? 0
        self.maxLat = lats.max() ?? 1
        self.minLon = lons.min() ?? 0
        self.maxLon = lons.max() ?? 1
        self.paddingFrac = padding
    }

    /// Project a single coordinate into view space (points).
    func project(to size: CGSize, coord: CLLocationCoordinate2D) -> CGPoint {
        // Normalize to 0..1 in both axes
        let latSpan = max(maxLat - minLat, .leastNonzeroMagnitude)
        let lonSpan = max(maxLon - minLon, .leastNonzeroMagnitude)

        // y increases downward in view space, so flip latitude
        let u = (coord.longitude - minLon) / lonSpan               // 0..1
        let v = (maxLat - coord.latitude) / latSpan                // 0..1 (flipped)

        // Fit into square with padding, then letterbox to view size preserving aspect
        let pad = paddingFrac
        let inner = CGSize(width: size.width * (1 - 2*pad),
                           height: size.height * (1 - 2*pad))

        // Choose uniform scale to preserve aspect ratio
        let scale = min(inner.width, inner.height)
        let offsetX = (size.width - scale) * 0.5
        let offsetY = (size.height - scale) * 0.5

        let x = offsetX + pad * size.width  + CGFloat(u) * scale
        let y = offsetY + pad * size.height + CGFloat(v) * scale
        return CGPoint(x: x, y: y)
    }

    /// Convenience: project an array of coordinates.
    func projectAll(to size: CGSize, points: [TrackPoint]) -> [CGPoint] {
        points.map { project(to: size, coord: $0.coord) }
    }
}
