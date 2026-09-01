import SwiftUI
import QuickLook

struct LibraryView: View {
    @StateObject private var store = ScanLibraryStore.shared
    @State private var selectedEntry: ScanEntry? = nil
    @State private var previewURL: URL? = nil

    @State private var scanToRename: ScanEntry? = nil
    @State private var newScanName: String = ""
    @State private var showInvalidFileAlert = false

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
            .alert("Rename Scan", isPresented: Binding(
                get: { scanToRename != nil },
                set: { if !$0 { scanToRename = nil } }
            )) {
                TextField("Name", text: $newScanName)
                Button("Cancel", role: .cancel) {
                    scanToRename = nil
                }
                Button("Save") {
                    if let entry = scanToRename, !newScanName.trimmingCharacters(in: .whitespaces).isEmpty {
                        store.rename(entry: entry, to: newScanName)
                    }
                    scanToRename = nil
                }
            } message: {
                Text("Enter a new name for this scan.")
            }
            .alert("Invalid Model", isPresented: $showInvalidFileAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This scan contains no actual 3D data. This usually happens when scanning on an unsupported device or simulator.")
            }
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
                    .onTapGesture {
                        previewURL = entry.modelURL
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            ExportManager.shared.export(modelURL: entry.modelURL)
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                        
                        Button {
                            newScanName = entry.name
                            scanToRename = entry
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        .tint(.orange)
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
