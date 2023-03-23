import SwiftUI

struct DownloadButton: View {
    @StateObject
    private var controller: DownloadButtonController

    init(
        for itemId: String,
        albumRepo: AlbumRepository = AlbumRepository.shared,
        songRepo: SongRepository = SongRepository.shared
    ) {
        self._controller = StateObject(
            wrappedValue: DownloadButtonController(
                itemId: itemId,
                albumRepo: albumRepo,
                songRepo: songRepo
            )
        )
    }

    var body: some View {
        Button {
            Task(priority: .background) { await self.controller.onClick() }
        } label: {
            if controller.inProgress {
                ProgressView()
            } else {
                DownloadedIcon(isDownloaded: $controller.isDownloaded)
            }
        }
        .onAppear { Task(priority: .background) { await controller.setDownloaded() }}
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

    let itemId: String
    var albumRepo: AlbumRepository
    var songRepo: SongRepository

    init(
        itemId: String,
        albumRepo: AlbumRepository,
        songRepo: SongRepository
    ) {
        self.itemId = itemId
        self.albumRepo = albumRepo
        self.songRepo = songRepo
    }

    func onClick() async {
        await self.isDownloaded ? removeItem() : downloadItem()
    }

    func setDownloaded() async {
        if let item = await self.songRepo.getSong(by: self.itemId) {
            DispatchQueue.main.async { self.isDownloaded = item.isDownloaded }
        }
    }

    private func setInProgress(_ inProgress: Bool) {
        DispatchQueue.main.async { self.inProgress = inProgress }
    }

    private func downloadItem() async {
        self.setInProgress(true)
        do {
            try await self.doDownloadItem()
            await self.updateStatus(isDownloaded: true)
        } catch {
            print("Download failed", error)
        }
        self.setInProgress(false)
    }

    private func removeItem() async {
        self.setInProgress(true)
        do {
            try await self.doRemoveItem()
            await self.updateStatus(isDownloaded: false)
        } catch {
            print("Remove item failed", error)
        }
        self.setInProgress(false)
    }

    private func doRemoveItem() async throws {
        // TODO: support for albums (bulk remove)
        try await MediaRepository.shared.removeItem(id: self.itemId)
    }

    private func doDownloadItem() async throws {
        // TODO: support for albums (bulk download)
        try await MediaRepository.shared.fetchItem(by: self.itemId)
    }

    private func updateStatus(isDownloaded: Bool) async {
        // TODO: support for albums (check all items)
        do {
            try await self.songRepo.setDownloaded(itemId: self.itemId, isDownloaded)
            await self.setDownloaded()
        } catch {
            print("Failed to update downloaded status: \(error)")
        }
    }
}
