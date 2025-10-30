//
//  RunCard.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//

import CoreLocation
import SwiftUI

private let cardBG = Color(.secondarySystemBackground)
private let borderColor = Color.black.opacity(0.08)

struct RunCard: View {
    let run: Run

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top metrics line
            HStack {
                Text(formatMiles(run.distanceMeters))
                    .font(.system(size: 36, weight: .black, design: .rounded))
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(run.title ?? formattedDate(run.importedAt))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let loc = run.location {
                        Text(loc)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Sub metrics
            HStack(spacing: 18) {
                Text("\(formatPace(run.avgPaceSecPerMile)) /mi")
                    .font(.headline)
                Text("—")
                Text(formatHMS(run.durationSeconds))
                    .font(.headline)
            }
            .foregroundColor(.secondary)

            // Glow preview (reusing your TrailPreview code path: small Canvas)
            MiniTrailPreview(points: run.previewPoints.compactMap { $0.count == 2 ? CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) : nil })
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .padding(16)
        .background(cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(borderColor, lineWidth: 1.5)
        )
    }
}

// MARK: - Helpers

private func formatMiles(_ meters: Double) -> String {
    let miles = meters / 1609.34
    return String(format: "%.2f mi", miles)
}

private func formatPace(_ secPerMile: Double) -> String {
    guard secPerMile.isFinite, secPerMile > 0 else { return "—" }
    let m = Int(secPerMile) / 60
    let s = Int(secPerMile) % 60
    return String(format: "%d:%02d", m, s)
}

private func formatHMS(_ s: TimeInterval) -> String {
    let t = max(0, Int(s))
    return String(format: "%d:%02d:%02d", t / 3600, (t % 3600) / 60, t % 60)
}

private func formattedDate(_ d: Date) -> String {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .short
    return f.string(from: d)
}
