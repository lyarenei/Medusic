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
        purgeImagesButton()
        purgeLibraryDataButton()
        purgeDownloadsButton()
        purgeAllButton()
        resetToDefaultButton()
            .disabled(true)
    }

    @ViewBuilder
    private func purgeImagesButton() -> some View {
        AlertButton(
            btnText: "Delete all images",
            alertTitle: "Delete images",
            alertMessage: "This will delete all cached images",
            alertPrimaryBtnText: "Delete",
            alertPrimaryAction: purgeImages
        )
    }

    @ViewBuilder
    private func purgeLibraryDataButton() -> some View {
        AlertButton(
            btnText: "Reset library",
            alertTitle: "Reset library",
            alertMessage: "This will remove all local library data from the device",
            alertPrimaryBtnText: "Reset"
        ) {
            Task {
                do {
                    try await purgeLibraryData()
                } catch {
                    print("Resetting library data failed: \(error.localizedDescription)")
                }
            }
        }
    }

    @ViewBuilder
    private func purgeDownloadsButton() -> some View {
        AlertButton(
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
    private func purgeAllButton() -> some View {
        AlertButton(
            btnText: "Remove everything",
            alertTitle: "Remove everything",
            alertMessage: "This will reset the library data and remove images and downloads",
            alertPrimaryBtnText: "Remove"
        ) {
            Task {
                do {
                    try await purgeAll()
                } catch {
                    print("Purging failed: \(error.localizedDescription)")
                }
            }
        }
    }

    @ViewBuilder
    private func resetToDefaultButton() -> some View {
        AlertButton(
            btnText: "Reset to defaults",
            alertTitle: "Reset defaults",
            alertMessage: "This will reset the library data and remove images and downloads as well as reset all settings to their defaults",
            alertPrimaryBtnText: "Reset",
            alertPrimaryAction: resetToDefault
        )
    }

    private func resetToDefault() {
        // TODO: clear cache and all settings
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

struct AlertButton: View {
    @State
    var showConfirm = false

    var btnText: String

    var alertTitle: String
    var alertMessage: String

    var alertPrimaryBtnText: String
    var alertPrimaryAction: () -> Void

    init(
        btnText: String,
        alertTitle: String,
        alertMessage: String,
        alertPrimaryBtnText: String,
        alertPrimaryAction: @escaping () -> Void
    ) {
        self.btnText = btnText
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.alertPrimaryBtnText = alertPrimaryBtnText
        self.alertPrimaryAction = alertPrimaryAction
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            Button(btnText) {
                showConfirm = true
            }
            .alert(alertTitle, isPresented: $showConfirm) {
                Button(alertPrimaryBtnText, role: .destructive) { alertPrimaryAction() }
                Button("Cancel", role: .cancel) { showConfirm = false }
            } message: {
                Text(alertMessage)
            }
        } else {
            Button(btnText) {
                showConfirm = true
            }
            .alert(isPresented: $showConfirm) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    primaryButton: .destructive(Text(alertPrimaryBtnText)) { alertPrimaryAction() },
                    secondaryButton: .default(Text("Cancel")) { showConfirm = false }
                )
            }
        }
    }
}
