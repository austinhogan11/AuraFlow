//
//  RunStore.swift
//  AuraFlow
//
//  Created by Austin on 10/30/25.
//
import Combine
import Foundation

@MainActor
final class RunStore: ObservableObject {
    @Published private(set) var runs: [Run] = []

    private let maxCount = 7
    private let fileURL: URL

    init() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = doc.appendingPathComponent("runs.json")
        load()
    }

    func add(_ run: Run) {
        runs.insert(run, at: 0) // newest on top
        if runs.count > maxCount { runs.removeLast() }
        save()
    }

    func remove(_ id: Run.ID) {
        runs.removeAll { $0.id == id }
        save()
    }

    // MARK: persistence

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        do {
            runs = try JSONDecoder().decode([Run].self, from: data)
        } catch {
            print("RunStore load error:", error)
            runs = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(runs)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("RunStore save error:", error)
        }
    }
}
