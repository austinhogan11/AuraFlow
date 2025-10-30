//
//  ImportView.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//
/*
 Purpose: Tiny UI to pick a GPX and show basic stats.
 What it does:
     •    Presents a file picker (.fileImporter).
     •    Calls GPXParser().parse(url:) for the selected file.
     •    Stores the resulting Track in state and displays:
     •    point count
     •    distance (miles)
     •    duration (m:ss)
     •    average pace (m:ss /mi)
     •    Simple formatters for miles, duration, and pace.
 */
import SwiftUI
import UniformTypeIdentifiers

private let gold = Color(red: 0.98, green: 0.86, blue: 0.35)

// Allow explicit GPX UTI (fallback to XML if not resolvable on this OS)
extension UTType {
    static var gpx: UTType {
        UTType(filenameExtension: "gpx") ?? .xml
    }
}

struct ImportView: View {
    @State private var isImporterPresented = false
    @State private var track: Track?
    @State private var error: String?
    @EnvironmentObject private var store: RunStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("AuraFlow").font(.largeTitle).bold()

                Button("Import GPX") { isImporterPresented = true }
                    .buttonStyle(.borderedProminent)
                    .tint(gold)

                if let t = track {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Points: \(t.points.count)")
                        Text("Distance: \(formatMiles(t.distance))")
                        Text("Duration: \(formatDuration(t.duration))")
                        Text("Avg Pace: \(formatPace(t.averagePaceSecondsPerMile)) /mi")
                    }
                    .padding()
                    NavigationLink("Open Preview") {
                        TrailPreviewView(track: t, preset: .classicGlow)
                    }
                    .buttonStyle(.bordered)
                }

                if let e = error {
                    Text(e).foregroundColor(.red)
                }
                Spacer()
            }
            .padding()
            .preferredColorScheme(.light)
            .fileImporter(isPresented: $isImporterPresented,
                          allowedContentTypes: [UTType.gpx, .xml], // Prefer GPX, allow XML fallback
                          allowsMultipleSelection: false)
            {
                result in
                switch result {
                case let .success(urls):
                    guard let url = urls.first else { return }
                    // Security-scoped access is required for Files/iCloud URLs
                    let needsAccess = url.startAccessingSecurityScopedResource()
                    defer { if needsAccess { url.stopAccessingSecurityScopedResource() } }
                    do {
                        let parsed = try GPXParser().parse(url: url)
                        // Save lightweight snapshot (ring buffer handled by RunStore)
                        let run = Run.from(track: parsed,
                                           title: formattedTitle(parsed),
                                           location: nil)
                        store.add(run)

                        // Keep in-state for immediate preview if user stays here
                        track = parsed
                        error = nil
                        print("Imported GPX:", url.lastPathComponent, "points:", parsed.points.count)

                        // Return to Home list so the new card appears
                        dismiss()
                    } catch {
                        self.error = error.localizedDescription
                        print("GPX parse error:", error)
                    }
                case let .failure(err):
                    error = err.localizedDescription
                }
            }
        }
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
        let m = Int(secPerMile) / 60
        let s = Int(secPerMile) % 60
        return String(format: "%d:%02d", m, s)
    }

    private func formattedTitle(_ track: Track) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: .now)
    }
}
