//
//  TrailPreviewView.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//

import CoreLocation
import SwiftUI

private let gold = Color(red: 0.98, green: 0.86, blue: 0.35)

struct TrailPreviewView: View {
    let track: Track
    @State var preset: TrailPreset = .classicGlow
    private let paddingFrac: CGFloat = 0.08

    var body: some View {
        VStack(spacing: 12) {
            // Preset picker
            Picker("Style", selection: $preset) {
                ForEach(TrailPreset.all) { p in
                    Text(p.name).tag(p)
                }
            }
            .pickerStyle(.segmented)
            .tint(gold)
            .padding(.horizontal)

            // Canvas preview
            GeometryReader { geo in
                let _ = geo.size
                Canvas { ctx, size in
                    guard !track.points.isEmpty else { return }

                    // 1) Project lat/lon -> view points
                    let projector = GeoProjector(points: track.points, padding: paddingFrac)
                    let pts = projector.projectAll(to: size, points: track.points)
                    guard pts.count > 1 else { return }

                    // 2) Make a single path
                    var path = Path()
                    path.addLines(pts)

                    // 3) Draw glow (back layers, blurred)
                    let glowStrokeWidth = preset.lineWidth * 2.4

                    // Start a new Graphics layer so filters don't leak into the main stroke
                    ctx.drawLayer { layer in
                        layer.addFilter(.blur(radius: preset.glow))
                        layer.stroke(
                            path,
                            with: .color((preset.colors.first ?? .white).opacity(0.30)),
                            lineWidth: glowStrokeWidth
                        )

                        // Optional second, softer outer glow
                        layer.addFilter(.blur(radius: preset.glow * 0.6))
                        layer.stroke(
                            path,
                            with: .color((preset.colors.last ?? .yellow).opacity(0.18)),
                            lineWidth: glowStrokeWidth * 1.25
                        )
                    }

                    // 4) Main gradient stroke
                    let grad = Gradient(colors: preset.colors)
                    ctx.stroke(
                        path,
                        with: GraphicsContext.Shading.linearGradient(
                            grad,
                            startPoint: CGPoint.zero,
                            endPoint: CGPoint(x: size.width, y: size.height)
                        ),
                        lineWidth: preset.lineWidth
                    )
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal)
            }
            .frame(height: 400)

            // Simple stats overlay
            HStack(spacing: 16) {
                StatChip(title: "Distance", value: formatMiles(track.distance))
                StatChip(title: "Duration", value: formatDuration(track.duration))
                StatChip(title: "Avg Pace", value: formatPace(track.averagePaceSecondsPerMile) + " /mi")
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Preview")
        .preferredColorScheme(.light)
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    // MARK: - Formatters

    private func formatMiles(_ meters: Double) -> String {
        let miles = meters / 1609.34
        return String(format: "%.2f mi", miles)
    }

    private func formatDuration(_ s: TimeInterval) -> String {
        let total = max(0, Int(s))
        let h = total / 3600
        let m = (total % 3600) / 60
        let sec = total % 60
        return String(format: "%d:%02d:%02d", h, m, sec)
    }

    private func formatPace(_ secPerMile: Double) -> String {
        guard secPerMile.isFinite, secPerMile > 0 else { return "—" }
        let m = Int(secPerMile) / 60, s = Int(secPerMile) % 60
        return String(format: "%d:%02d", m, s)
    }
}

private struct StatChip: View {
    let title: String
    let value: String
    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.headline).foregroundColor(.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 1))
        .clipShape(Capsule())
    }
}
