import Boutique
import Defaults
import Kingfisher
import SwiftUI

struct AdvancedSettingsScreen: View {
    var body: some View {
        List {
            MaxCacheSize()

            Section {
                PurgeOptions()
            }
            .buttonStyle(.plain)
            .foregroundColor(.red)
        }
        .listStyle(.grouped)
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct AdvancedSettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsScreen()
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

private struct PurgeOptions: View {
    @Stored(in: .albums)
    var albums: [Album]

    @Stored(in: .songs)
    var songs: [Song]

    @Stored(in: .downloadedSongs)
    var downloadedSongs: [Song]

    @State
    var showConfirm = false

    var body: some View {
        purgeLibraryDataButton()
        purgeDownloadsButton()
        resetToDefaultButton()
    }

    @ViewBuilder
    private func purgeLibraryDataButton() -> some View {
        ConfirmButton(
            btnText: "Reset library",
            alertTitle: "Reset library",
            alertMessage: "This will clear all caches and local library data from the device",
            alertPrimaryBtnText: "Reset"
        ) {
            Task {
                do {
                    purgeImages()
                    try await purgeLibraryData()
                } catch {
                    print("Resetting library data failed: \(error.localizedDescription)")
                }
            }
        }
    }

    @ViewBuilder
    private func purgeDownloadsButton() -> some View {
        ConfirmButton(
            btnText: "Remove all downloads",
            alertTitle: "Remove all downloads",
            alertMessage: "This will remove all downloaded songs",
            alertPrimaryBtnText: "Remove"
        ) {
            do {
                try purgeDownloads()
            } catch {
                print("Failed to remove downloaded data: \(error.localizedDescription)")
            }
        }
    }

    @ViewBuilder
    private func resetToDefaultButton() -> some View {
        ConfirmButton(
            btnText: "Reset JellyMusic",
            alertTitle: "Reset to defaults",
            alertMessage: "This will delete everything and reset all settings to their defaults",
            alertPrimaryBtnText: "Reset",
            alertPrimaryAction: resetToDefault
        )
    }

    private func resetToDefault() {
        Task {
            do {
                try await purgeAll()
            } catch {
                print("Reset failed: \(error.localizedDescription)")
            }

            Defaults.removeAll()
        }
    }

    private func purgeImages() {
        Kingfisher.ImageCache.default.clearMemoryCache()
        Kingfisher.ImageCache.default.clearDiskCache()
    }

    private func purgeLibraryData() async throws {
        try await $albums.removeAll()
        try await $songs.removeAll()
        try await $downloadedSongs.removeAll()
    }

    private func purgeDownloads() throws {
        try FileRepository.shared.removeAllFiles()
    }

    private func purgeAll() async throws {
        purgeImages()
        try await purgeLibraryData()
        try purgeDownloads()
    }
}
