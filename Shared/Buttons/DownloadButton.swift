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
    private var item: Item
    private var textDownload: String?
    private var textRemove: String?
    private var layout: ButtonLayout = .horizontal
    private var downloader: Downloader

    init(
        item: Item,
        textDownload: String? = nil,
        textRemove: String? = nil,
        fileRepo: FileRepository = .shared,
        downloader: Downloader = .shared
    ) {
        self.item = item
        self.textDownload = textDownload
        self.textRemove = textRemove

        self.downloader = downloader
        if let song = item as? Song {
            self.isDownloaded = fileRepo.fileExists(for: song)
        }
    }

    var body: some View {
        button
            .onAppear { handleOnAppear() }
            .onReceive(NotificationCenter.default.publisher(for: .SongFileDownloaded)) { event in
                guard let data = event.userInfo,
                      let song = data["song"] as? Song,
                      song.id == item.id
                else { return }

                inProgress = false
                isDownloaded = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .SongFileDeleted)) { event in
                guard let data = event.userInfo,
                      let song = data["song"] as? Song,
                      song.id == item.id
                else { return }

                isDownloaded = false
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
                switch layout {
                case .horizontal:
                    hLayout()
                case .vertical:
                    vLayout()
                }
            }
        }
    }

    @ViewBuilder
    private var icon: some View {
        Image(systemSymbol: isDownloaded ? .trash : .icloudAndArrowDown)
            .scaledToFit()
    }

    @ViewBuilder
    private func hLayout() -> some View {
        HStack {
            icon
            buttonText(isDownloaded ? textRemove : textDownload)
        }
    }

    @ViewBuilder
    private func vLayout() -> some View {
        VStack {
            icon
            buttonText(isDownloaded ? textRemove : textDownload)
        }
    }

    @ViewBuilder
    private func buttonText(_ text: String?) -> some View {
        if let text {
            Text(text)
        }
    }

    private func handleOnAppear() {
        switch item {
        case let item as Song:
            isDownloaded = fileRepo.fileExists(for: item)
            inProgress = downloader.queue.contains { $0 == item }
        default:
            isDownloaded = false
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
        case let item as Album:
            let songs = await library.getSongs(for: item)
            try await downloader.download(songs)
        case let item as Song:
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
        case let item as Album:
            let songs = await library.getSongs(for: item)
            try await fileRepo.removeFiles(for: songs)
        case let item as Song:
            try await fileRepo.removeFile(for: item)
        default:
            let type = type(of: item)
            logger.info("Removing \(type) is not supported")
            Alerts.info("Remove is not supported")
        }
    }

    enum ButtonLayout {
        case horizontal
        case vertical
    }
}

extension DownloadButton {
    func setLayout(_ layout: ButtonLayout) -> DownloadButton {
        var view = self
        view.layout = layout
        return view
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

#Preview("Horizontal") {
    DownloadButton(item: PreviewData.albums.first!, textDownload: "Download", textRemove: "Remove")
        .setLayout(.horizontal)
        .font(.title)
        .environmentObject(PreviewUtils.libraryRepo)
        .environmentObject(PreviewUtils.fileRepo)
}

#Preview("Vertical") {
    DownloadButton(item: PreviewData.albums.first!, textDownload: "Download", textRemove: "Remove")
        .setLayout(.vertical)
        .font(.title)
        .environmentObject(PreviewUtils.libraryRepo)
        .environmentObject(PreviewUtils.fileRepo)
}

// swiftlint:enable all
#endif
