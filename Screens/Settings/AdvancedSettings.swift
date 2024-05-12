import ButtonKit
import DebouncedOnChange
import Defaults
import Kingfisher
import SwiftUI

struct AdvancedSettings: View {
    @EnvironmentObject
    private var fileRepo: FileRepository

    @EnvironmentObject
    private var library: LibraryRepository

    var body: some View {
        List {
            MaxCacheSize()
            ClearArtworkCache()
            RemoveDownloads()

            forceLibraryRefreshButton
            checkDownloadsIntegrityButton
            resetToDefaultsButton
                .foregroundColor(.red)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var forceLibraryRefreshButton: some View {
        AsyncButton {
            do {
                try await library.refreshAll()
            } catch {
                print("Failed to refresh library: \(error.localizedDescription)")
                Alerts.error("Library refresh failed")
            }
        } label: {
            Text("Force library refresh")
        }
        .disabledWhenLoading()
    }

    @ViewBuilder
    private var checkDownloadsIntegrityButton: some View {
        Section {
            AsyncButton {
                do {
                    try await fileRepo.checkIntegrity()
                    Alerts.done("Integrity check finished")
                } catch {
                    Alerts.error("Integrity check failed")
                }
            } label: {
                Text("Check downloads integrity")
            }
            .disabledWhenLoading()
        } footer: {
            Text("Check the integrity of downloaded files and attempt to fix mismatches. This check is automatically run on every app launch.")
        }
    }

    @ViewBuilder
    private var resetToDefaultsButton: some View {
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

#Preview {
    AdvancedSettings()
        .environmentObject(PreviewUtils.fileRepo)
        .environmentObject(PreviewUtils.libraryRepo)
}

#endif

private struct MaxCacheSize: View {
    @Default(.maxCacheSize)
    var maxCacheSize

    @EnvironmentObject
    private var fileRepo: FileRepository

    var body: some View {
        InlineNumberInputComponent(
            title: "Max cache size (MB)",
            inputNumber: $maxCacheSize,
            formatter: getFormatter()
        )
        .onChange(of: maxCacheSize, debounceTime: Duration.seconds(5)) { newValue in
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
        .task { await calculateSize() }
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
                btnText: "Remove all downloads",
                alertTitle: "Remove downloaded songs",
                alertMessage: .empty,
                alertPrimaryBtnText: "Confirm",
                alertPrimaryAction: onConfirm
            )
            .foregroundColor(.red)
        } footer: {
            Text("Current size: \(String(format: "%.1f", sizeMB)) MB")
        }
        .task { await calculateSize() }
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
                Alerts.error("Removing files failed")
            }
        }
    }

    @MainActor
    private func calculateSize() async {
        do {
            sizeMB = try fileRepo.downloadedFilesSizeInMB()
        } catch {
            print("Failed to get file cache size: \(error.localizedDescription)")
            Alerts.error("Failed to get file size")
        }
    }
}
