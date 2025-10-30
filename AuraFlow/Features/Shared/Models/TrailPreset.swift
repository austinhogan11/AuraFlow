import SwiftUI

/// Visual style for rendering a trail.
struct TrailPreset: Identifiable, Hashable {
    /// Stable identifier used for equality/hash (keeps Picker happy).
    let id: String
    let name: String
    let colors: [Color]
    let lineWidth: CGFloat
    let glow: CGFloat

    // Presets
    static let classicGlow = TrailPreset(
        id: "classicGlow",
        name: "Classic Glow",
        colors: [Color.white.opacity(0.95), Color.yellow.opacity(0.9)],
        lineWidth: 8,
        glow: 20
    )

    static let neonVelocity = TrailPreset(
        id: "neonVelocity",
        name: "Neon Velocity",
        colors: [Color.cyan, Color.blue, Color.purple],
        lineWidth: 10,
        glow: 26
    )

    static let heatmapPulse = TrailPreset(
        id: "heatmapPulse",
        name: "Heatmap Pulse",
        colors: [Color.orange, Color.red],
        lineWidth: 9,
        glow: 24
    )

    static let all: [TrailPreset] = [.classicGlow, .neonVelocity, .heatmapPulse]

    // Hash/Equatable by id only (stable; avoids hashing Color)
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: TrailPreset, rhs: TrailPreset) -> Bool { lhs.id == rhs.id }
}
