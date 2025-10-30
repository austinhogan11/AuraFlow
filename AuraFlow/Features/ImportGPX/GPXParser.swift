//
//  GPXParser.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//
import CoreLocation
import Foundation

/// Minimal, dependency-free GPX parser.
/// Parses <trkpt lat=".." lon=".."><ele>..</ele><time>..</time></trkpt>
final class GPXParser: NSObject {
    func parse(url: URL) throws -> Track {
        let delegate = GPXDelegate()
        guard let parser = XMLParser(contentsOf: url) else {
            throw NSError(domain: "GPXParser", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot open file"])
        }
        parser.delegate = delegate
        guard parser.parse() else {
            throw parser.parserError ?? NSError(domain: "GPXParser", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unknown GPX parse error"])
        }
        var pts = delegate.points
        TrackPostProcess.fillDistanceAndSpeed(points: &pts)
        return Track(points: pts)
    }
}

// MARK: - XML delegate

private final class GPXDelegate: NSObject, XMLParserDelegate {
    var points: [TrackPoint] = []

    private var currentElement = ""
    private var currentLat: Double?
    private var currentLon: Double?
    private var currentEle: Double?
    private var currentTime: String?
    private var inTrkpt = false

    private static let isoFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private func parseDate(_ s: String) -> Date? {
        if let d = Self.isoFrac.date(from: s) { return d }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: s)
    }

    func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes: [String: String] = [:])
    {
        currentElement = name
        if name == "trkpt" {
            inTrkpt = true
            currentLat = Double(attributes["lat"] ?? "")
            currentLon = Double(attributes["lon"] ?? "")
            currentEle = nil
            currentTime = nil
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard inTrkpt else { return }
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        switch currentElement {
        case "ele": currentEle = Double(trimmed)
        case "time": currentTime = (currentTime ?? "") + trimmed
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?,
                qualifiedName qName: String?)
    {
        if name == "trkpt" {
            defer { inTrkpt = false }
            guard let lat = currentLat, let lon = currentLon,
                  let tsStr = currentTime, let ts = parseDate(tsStr) else { return }
            points.append(
                TrackPoint(
                    coord: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    elevation: currentEle,
                    timestamp: ts
                )
            )
        }
        currentElement = ""
    }
}
