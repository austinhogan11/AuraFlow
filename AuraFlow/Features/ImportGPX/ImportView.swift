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

struct ImportView: View {
    @State private var isImporterPresented = false
    @State private var track: Track?
    @State private var error: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("AuraFlow").font(.largeTitle).bold()

            Button("Import GPX") { isImporterPresented = true }
                .buttonStyle(.borderedProminent)

            if let t = track {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Points: \(t.points.count)")
                    Text("Distance: \(formatMiles(t.distance))")
                    Text("Duration: \(formatDuration(t.duration))")
                    Text("Avg Pace: \(formatPace(t.averagePaceSecondsPerMile)) /mi")
                }
                .padding()
            }

            if let e = error {
                Text(e).foregroundColor(.red)
            }
            Spacer()
        }
        .padding()
        .fileImporter(isPresented: $isImporterPresented,
                      allowedContentTypes: [.xml], // GPX is XML; we’ll later narrow with UTType if needed
                      allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                do {
                    let parsed = try GPXParser().parse(url: url)
                    self.track = parsed
                    self.error = nil
                } catch {
                    self.error = error.localizedDescription
                }
            case .failure(let err):
                self.error = err.localizedDescription
            }
        }
    }

    // MARK: - Formatters
    private func formatMiles(_ meters: Double) -> String {
        let miles = meters / 1609.34
        return String(format: "%.2f mi", miles)
    }

    private func formatDuration(_ s: TimeInterval) -> String {
        let m = Int(s) / 60
        let sec = Int(s) % 60
        return String(format: "%d:%02d", m, sec)
    }

    private func formatPace(_ secPerMile: Double) -> String {
        guard secPerMile.isFinite && secPerMile > 0 else { return "—" }
        let m = Int(secPerMile) / 60
        let s = Int(secPerMile) % 60
        return String(format: "%d:%02d", m, s)
    }
}
