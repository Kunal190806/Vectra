import SwiftUI
import QuickLook

struct LibraryView: View {
    @StateObject private var store = ScanLibraryStore.shared
    @State private var selectedEntry: ScanEntry? = nil
    @State private var previewURL: URL? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.12).ignoresSafeArea()

                if store.entries.isEmpty {
                    emptyState
                } else {
                    scanList
                }
            }
            .navigationTitle("Scan Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .quickLookPreview($previewURL)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 64))
                .foregroundColor(Color.white.opacity(0.2))
            Text("No Scans Yet")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Capture your first 3D scan using the Scan tab.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - List

    private var scanList: some View {
        List {
            ForEach(store.entries) { entry in
                ScanEntryRow(entry: entry)
                    .listRowBackground(Color(red: 0.1, green: 0.1, blue: 0.18))
                    .listRowSeparatorTint(Color.white.opacity(0.08))
                    .onTapGesture { previewURL = entry.modelURL }
                    .swipeActions(edge: .leading) {
                        Button {
                            ExportManager.shared.export(modelURL: entry.modelURL)
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                    }
            }
            .onDelete(perform: store.delete)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct ScanEntryRow: View {
    let entry: ScanEntry

    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [Color(red: 0.2, green: 0.3, blue: 0.6),
                             Color(red: 0.3, green: 0.2, blue: 0.5)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "cube.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(entry.date, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                HStack(spacing: 8) {
                    Label("\(entry.frameCount) frames", systemImage: "photo.stack")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Label(String(format: "%.0fs", entry.durationSeconds), systemImage: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}
