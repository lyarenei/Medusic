import ButtonKit
import Combine
import OSLog
import SFSafeSymbols
import SwiftUI

struct DownloadButton<Item: JellyfinItem>: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @EnvironmentObject
    private var fileRepo: FileRepository

    @State
    private var isDownloaded = false

    @State
    private var inProgress = false

    private var logger = Logger.library
    private let item: Item
    private let textDownload: String
    private let textRemove: String
    private let downloader: Downloader

    init(
        item: Item,
        textDownload: String = .empty,
        textRemove: String = .empty,
        fileRepo: FileRepository = .shared,
        downloader: Downloader = .shared
    ) {
        self.item = item
        self.textDownload = textDownload
        self.textRemove = textRemove

        self.downloader = downloader

        switch item {
        case let item as AlbumDto:
            // TODO: support for albums
            break
        case let item as SongDto:
            self.isDownloaded = item.isDownloaded
        default:
            // Unsupported type
            break
        }
    }

    var body: some View {
        button
            .onAppear { updateInProgress() }
            .onReceive(NotificationCenter.default.publisher(for: .SongFileDownloaded)) { event in
                guard let data = event.userInfo,
                      let songId = data["songId"] as? String,
                      songId == item.id
                else { return }

                inProgress = false
            }
    }

    @ViewBuilder
    private var button: some View {
        Button {
            action()
        } label: {
            if inProgress {
                ProgressView()
                    .scaledToFit()
            } else {
                label
            }
        }
        .disabled(inProgress)
    }

    @ViewBuilder
    private var label: some View {
        if textDownload.isEmpty || textRemove.isEmpty {
            Image(systemSymbol: isDownloaded ? .trash : .icloudAndArrowDown)
                .scaledToFit()
        } else {
            Label(isDownloaded ? textRemove : textDownload) {
                Image(systemSymbol: isDownloaded ? .trash : .icloudAndArrowDown)
            }
        }
    }

    private func updateInProgress() {
        switch item {
        case let item as SongDto:
            inProgress = downloader.downloadQueue.contains { $0 == item }
        default:
            inProgress = false
        }
    }

    private func action() {
        Task {
            do {
                if isDownloaded {
                    try await removeAction()
                } else {
                    try await downloadAction()
                }
            } catch {
                if isDownloaded {
                    logger.warning("Remove action failed for item \(item.id): \(error.localizedDescription)")
                    Alerts.error("Remove failed")
                } else {
                    logger.warning("Download action failed for item \(item.id): \(error.localizedDescription)")
                    Alerts.error("Download failed")
                }
            }
        }
    }

    private func downloadAction() async throws {
        inProgress = true
        switch item {
        case let item as AlbumDto:
            let songs = await library.getSongs(for: item)
            try await downloader.download(songs)
        case let item as SongDto:
            try await downloader.download(item)
        default:
            inProgress = false
            let type = type(of: item)
            logger.info("Downloading \(type) is not supported")
            Alerts.info("Download is not supported")
        }
    }

    private func removeAction() async throws {
        switch item {
        case let item as AlbumDto:
            let songs = await library.getSongs(for: item)
            try await fileRepo.removeFiles(for: songs)
        case let item as SongDto:
            try await fileRepo.removeFile(for: item.id)
        default:
            let type = type(of: item)
            logger.info("Removing \(type) is not supported")
            Alerts.info("Remove is not supported")
        }
    }
}

#if DEBUG
// swiftlint:disable all

#Preview("Icon only") {
    DownloadButton(item: PreviewData.albums.first!)
        .font(.title)
        .environmentObject(PreviewUtils.libraryRepo)
        .environmentObject(PreviewUtils.fileRepo)
}

#Preview("Text + icon") {
    DownloadButton(item: PreviewData.albums.first!, textDownload: "Download", textRemove: "Remove")
        .font(.title)
        .environmentObject(PreviewUtils.libraryRepo)
        .environmentObject(PreviewUtils.fileRepo)
}

// swiftlint:enable all
#endif
