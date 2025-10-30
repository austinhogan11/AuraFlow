//
//  TrailPreset.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//

import SwiftUI

/// Visual style for rendering a trail.
struct TrailPreset: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let colors: [Color]     // gradient colors along the path
    let lineWidth: CGFloat  // main stroke width
    let glow: CGFloat       // blur radius for soft glow

    // --- Presets ---

    /// White/gold glow — clean and classy
    static let classicGlow = TrailPreset(
        name: "Classic Glow",
        colors: [Color.white.opacity(0.95),
                 Color.yellow.opacity(0.9)],
        lineWidth: 8,
        glow: 20
    )

    /// Cyan→blue→violet — fast neon look
    static let neonVelocity = TrailPreset(
        name: "Neon Velocity",
        colors: [Color.cyan, Color.blue, Color.purple],
        lineWidth: 10,
        glow: 26
    )

    /// Orange→red — heatmap vibe
    static let heatmapPulse = TrailPreset(
        name: "Heatmap Pulse",
        colors: [Color.orange, Color.red],
        lineWidth: 9,
        glow: 24
    )

    static let all: [TrailPreset] = [
        .classicGlow,
        .neonVelocity,
        .heatmapPulse
    ]
}
