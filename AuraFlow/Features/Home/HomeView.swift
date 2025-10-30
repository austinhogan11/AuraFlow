//
//  HomeView.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//

import CoreLocation
import SwiftUI

private let gold = Color(red: 0.98, green: 0.86, blue: 0.35)

struct HomeView: View {
    @StateObject private var store = RunStore()
    @State private var showSplash = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 16) {
                    // Title that starts centered, animates upward
                    Text("AuraFlow")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .padding(.top, showSplash ? 0 : 8)
                        .padding(.bottom, showSplash ? 0 : 8)
                        .frame(maxWidth: .infinity, alignment: showSplash ? .center : .top)
                        .animation(.spring(duration: 0.7, bounce: 0.3), value: showSplash)

                    if !showSplash {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(store.runs) { run in
                                    NavigationLink {
                                        // Build a Track stub for full preview from saved points
                                        let tp: [TrackPoint] = run.previewPoints.compactMap { pair in
                                            guard pair.count == 2 else { return nil }
                                            let coord = CLLocationCoordinate2D(latitude: pair[0], longitude: pair[1])
                                            return TrackPoint(coord: coord, elevation: nil, timestamp: Date())
                                        }
                                        let track = Track(points: tp) // will recompute derived fields
                                        TrailPreviewView(track: track, preset: .classicGlow)
                                    } label: {
                                        RunCard(run: run)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .padding(.top, showSplash ? 0 : 8)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Import") {
                        ImportView()
                            .environmentObject(store)
                    }
                    .tint(gold)
                }
            }
        }
        .preferredColorScheme(.light)
        .task {
            // simple splash delay then reveal list
            try? await Task.sleep(nanoseconds: 900_000_000) // 0.9s
            withAnimation { showSplash = false }
        }
        .environmentObject(store)
    }
}
