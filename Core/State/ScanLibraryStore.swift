import Foundation
import Combine

/// A saved scan entry persisted to disk.
struct ScanEntry: Identifiable, Codable {
    let id: UUID
    let name: String
    let date: Date
    let modelURL: URL
    let thumbnailURL: URL?
    let frameCount: Int
    let durationSeconds: Double
}

/// Persists scans to UserDefaults (encoded as JSON).
final class ScanLibraryStore: ObservableObject {
    static let shared = ScanLibraryStore()
    private init() { load() }

    private let storageKey = "vectra_scan_library"

    @Published var entries: [ScanEntry] = []

    func add(entry: ScanEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach { idx in
            let entry = entries[idx]
            try? FileManager.default.removeItem(at: entry.modelURL)
        }
        entries.remove(atOffsets: offsets)
        save()
    }

    func rename(entry: ScanEntry, to newName: String) {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            let updated = ScanEntry(
                id: entry.id,
                name: newName,
                date: entry.date,
                modelURL: entry.modelURL,
                thumbnailURL: entry.thumbnailURL,
                frameCount: entry.frameCount,
                durationSeconds: entry.durationSeconds
            )
            entries[idx] = updated
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ScanEntry].self, from: data) else { return }
        entries = decoded
    }
}
