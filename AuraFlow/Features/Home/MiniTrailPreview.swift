//
//  MiniTrailPreview.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//
import CoreLocation
import SwiftUI

struct MiniTrailPreview: View {
    let points: [CLLocationCoordinate2D]
    private let paddingFrac: CGFloat = 0.08

    var body: some View {
        GeometryReader { _ in
            Canvas { ctx, size in
                guard points.count > 1 else { return }
                let projector = GeoProjector(points: points.map { TrackPoint(coord: $0, elevation: nil, timestamp: .now) }, padding: paddingFrac)
                let pts = projector.projectAll(to: size, points: points.map { TrackPoint(coord: $0, elevation: nil, timestamp: .now) })
                var path = Path(); path.addLines(pts)

                let glowWidth: CGFloat = 8
                ctx.drawLayer { layer in
                    layer.addFilter(.blur(radius: 8))
                    layer.stroke(path, with: .color(Color.white.opacity(0.30)), lineWidth: glowWidth * 2)
                    layer.addFilter(.blur(radius: 4))
                    layer.stroke(path, with: .color(Color.yellow.opacity(0.18)), lineWidth: glowWidth * 2.2)
                }
                let grad = Gradient(colors: [.white, .yellow])
                ctx.stroke(path,
                           with: .linearGradient(grad, startPoint: .zero,
                                                 endPoint: CGPoint(x: size.width, y: size.height)),
                           lineWidth: glowWidth)
            }
            .background(Color(.tertiarySystemBackground))
        }
    }
}
