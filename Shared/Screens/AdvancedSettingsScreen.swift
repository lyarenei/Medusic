import Defaults
import Kingfisher
import SwiftUI
import SwiftUIBackports

struct AdvancedSettingsScreen: View {
    @EnvironmentObject
    private var fileRepo: FileRepository

    @EnvironmentObject
    private var albumRepo: AlbumRepository

    @EnvironmentObject
    private var songRepo: SongRepository

    var body: some View {
        List {
            MaxCacheSize()
            ClearArtworkCache()
            RemoveDownloads()

            forceLibraryRefresh()
            resetToDefaultsButton()
                .foregroundColor(.red)
        }
        .listStyle(.grouped)
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func forceLibraryRefresh() -> some View {
        Button {
            onForceLibraryRefresh()
        } label: {
            Text("Force library refresh")
        }
    }

    private func onForceLibraryRefresh() {
        Task {
            do {
                try await albumRepo.refresh()
                try await songRepo.refresh()
            } catch {
                print("Failed to refresh data: \(error.localizedDescription)")
            }
        }
    }

    @ViewBuilder
    private func resetToDefaultsButton() -> some View {
        ConfirmButton(
            btnText: "Reset settings to defaults",
            alertTitle: "Reset settings to defaults",
            alertMessage: .empty,
            alertPrimaryBtnText: "Reset"
        ) {
            Defaults.removeAll()
        }
    }
}

#if DEBUG
struct AdvancedSettingsScreen_Previews: PreviewProvider {
    static var fileRepo: FileRepository = .init(
        downloadedSongsStore: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid),
        downloadQueueStore: .previewStore(items: [], cacheIdentifier: \.uuid),
        apiClient: .init(previewEnabled: true)
    )

    static var albumRepo: AlbumRepository = .init(
        store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid),
        apiClient: .init(previewEnabled: true)
    )

    static var songRepo: SongRepository = .init(
        store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid),
        apiClient: .init(previewEnabled: true)
    )

    static var previews: some View {
        AdvancedSettingsScreen()
            .environmentObject(fileRepo)
            .environmentObject(albumRepo)
            .environmentObject(songRepo)
    }
}
#endif

private struct MaxCacheSize: View {
    @Default(.maxCacheSize)
    var maxCacheSize

    @ObservedObject
    var fileRepo: FileRepository

    init(fileRepo: FileRepository = .shared) {
        _fileRepo = ObservedObject(wrappedValue: fileRepo)
    }

    var body: some View {
        InlineNumberInputComponent(
            title: "Max cache size (MB)",
            inputNumber: $maxCacheSize,
            formatter: getFormatter()
        )
        .onChange(of: maxCacheSize, debounceTime: 5) { newValue in
            fileRepo.setCacheSizeLimit(newValue)
        }
    }

    private func getFormatter() -> NumberFormatter {
        let fmt = NumberFormatter()
        fmt.numberStyle = .none
        fmt.minimum = 50
        fmt.allowsFloats = false
        fmt.isLenient = false
        return fmt
    }
}

private struct ClearArtworkCache: View {
    @State
    private var sizeMB = 0.0

    var body: some View {
        Section {
            ConfirmButton(
                btnText: "Clear artwork cache",
                alertTitle: "Clear artwork cache",
                alertMessage: .empty,
                alertPrimaryBtnText: "Confirm",
                alertPrimaryAction: onConfirm
            )
            .foregroundColor(.red)
        } footer: {
            Text("Cache size: \(String(format: "%.1f", sizeMB)) MB")
        }
        .backport.task { await calculateSize() }
    }

    private func resetSize() {
        Task { @MainActor in
            sizeMB = 0
        }
    }

    @MainActor
    private func calculateSize() async {
        do {
            let sizeBytes = try await KingfisherManager.shared.cache.diskStorageSize
            sizeMB = Double(sizeBytes) / 1024 / 1024
        } catch {
            print("Failed to get image cache size: \(error.localizedDescription)")
        }
    }

    private func onConfirm() {
        Kingfisher.ImageCache.default.clearMemoryCache()
        Kingfisher.ImageCache.default.clearDiskCache()
        resetSize()
    }
}

private struct RemoveDownloads: View {
    @EnvironmentObject
    private var fileRepo: FileRepository

    @State
    private var sizeMB = 0.0

    var body: some View {
        Section {
            ConfirmButton(
                btnText: "Remove downloads",
                alertTitle: "Remove downloaded songs",
                alertMessage: .empty,
                alertPrimaryBtnText: "Confirm",
                alertPrimaryAction: onConfirm
            )
            .foregroundColor(.red)
        } footer: {
            Text("Current size: \(String(format: "%.1f", sizeMB)) MB")
        }
        .backport.task { await calculateSize() }
    }

    private func resetSize() {
        Task { @MainActor in
            sizeMB = 0
        }
    }

    private func onConfirm() {
        Task {
            do {
                try await fileRepo.removeAllFiles()
                resetSize()
            } catch {
                print("Failed to remove downloads: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    private func calculateSize() async {
        do {
            sizeMB = try fileRepo.downloadedFilesSizeInMB()
        } catch {
            print("Failed to get image cache size: \(error.localizedDescription)")
        }
    }
}
