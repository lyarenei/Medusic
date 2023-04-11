import Combine
import OSLog
import SwiftUI

struct DownloadButton: View {
    @StateObject
    private var controller: DownloadButtonController

    private var showText: Bool

    init(
        for itemId: String,
        showText: Bool = false,
        albumRepo: AlbumRepository = AlbumRepository.shared,
        songRepo: SongRepository = SongRepository.shared
    ) {
        self.showText = showText
        self._controller = StateObject(
            wrappedValue: DownloadButtonController(
                itemId: itemId,
                albumRepo: albumRepo,
                songRepo: songRepo
            )
        )
    }

    var body: some View {
        GeometryReader { reader in
            Button {
                Task(priority: .background) {
                    do {
                        try await self.controller.onClick()
                    } catch {
                        Logger.library.debug("Task for download button failed: \(error.localizedDescription)")
                    }
                }
            } label: {
                if controller.inProgress {
                    ProgressView()
                        .frame(
                            width: reader.size.width,
                            height: reader.size.height,
                            alignment: .center
                        )
                        .scaledToFit()
                } else {
                    if showText { Text(controller.buttonText) }
                    DownloadedIcon(isDownloaded: $controller.isDownloaded)
                }
            }
        }
        .onAppear { Task(priority: .background) { controller.setDownloaded() }}
    }
}

#if DEBUG
struct DownloadButton_Previews: PreviewProvider {
    static var previews: some View {
        DownloadButton(
            for: "1",
            albumRepo: AlbumRepository(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)),
            songRepo: SongRepository(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
    }
}
#endif

private final class DownloadButtonController: ObservableObject {
    @Published
    var inProgress: Bool = false

    @Published
    var isDownloaded: Bool = false

    @Published
    var buttonText: String = "Download"

    private let itemId: String
    private var albumRepo: AlbumRepository
    private var songRepo: SongRepository
    private var cancellables: Cancellables = []

    init(
        itemId: String,
        albumRepo: AlbumRepository,
        songRepo: SongRepository
    ) {
        self.itemId = itemId
        self.albumRepo = albumRepo
        self.songRepo = songRepo

        /*
        FileRepository.shared.$downloadQueue.sink { queue in
            let inQueue = queue.contains(where: { $0 == self.itemId })
            if inQueue {
                if !self.inProgress {
                    self.setInProgress(true)
                }
            } else {
                if self.inProgress {
                    self.setInProgress(false)
                    self.setDownloaded()
                }
            }
        }
        .store(in: &self.cancellables)
         */
    }

    func onClick() async throws {
        await self.isDownloaded ? try removeItem() : downloadItem()
    }

    func setDownloaded() {
        let fileExists = FileRepository.shared.fileURL(for: self.itemId) != nil
        DispatchQueue.main.async {
            self.isDownloaded = fileExists
            self.buttonText = fileExists ? "Remove" : "Download"
        }
    }

    private func setInProgress(_ inProgress: Bool) {
        DispatchQueue.main.async { self.inProgress = inProgress }
    }

    private func downloadItem() {
        // TODO: support for albums (bulk download)
        // FileRepository.shared.enqueueToDownload(song: itemId)
    }

    private func removeItem() async throws {
        // TODO: support for albums (bulk remove)
        // try FileRepository.shared.removeFile(song: itemId)
        setDownloaded()
    }
}
