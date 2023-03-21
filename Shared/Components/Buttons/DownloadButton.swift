import SwiftUI

struct DownloadButton: View {
    @Environment(\.albumRepo)
    private var albumRepo

    @Environment(\.songRepo)
    private var songRepo

    @Environment(\.mediaRepo)
    private var mediaRepo

    @State
    private var inProgress: Bool = false

    @State
    var item: any Unique & Downloadable

    var body: some View {
        Button {
            Task { await self.onClick() }
        } label: {
            if inProgress {
                ProgressView()
            } else {
                DownloadedIcon(isDownloaded: $item.isDownloaded)
            }
        }
    }

    private func onClick() async {
        await item.isDownloaded ? removeItem() : downloadItem()
    }

    private func downloadItem() async {
        self.inProgress = true
        do {
            try await self.doDownloadItem(self.item)
            await self.setDownloaded(true, for: self.item)
        } catch {
            print("Download failed", error)
        }
        self.inProgress = false
    }

    private func removeItem() async {
        self.inProgress = true
        do {
            try await self.doRemoveItem(self.item)
            await self.setDownloaded(false, for: self.item)
        } catch {
            print("Remove item failed", error)
        }
        self.inProgress = false
    }

    private func doRemoveItem(_ item: Any) async throws {
        switch item {
            case _ where item is Song:
                try await self.mediaRepo.removeItem(id: self.item.uuid)
            default:
                print("Cannot remove item - unrecognized type")
        }
    }

    private func doDownloadItem(_ item: Any) async throws {
        switch item {
            case _ where item is Song:
                try await self.mediaRepo.fetchItem(by: self.item.uuid)
            default:
                print("Cannot download item - unrecognized type")
        }
    }

    private func setDownloaded(_ isDownloaded: Bool, for item: Any) async {
        do {
            switch item {
                case _ where item is Album:
                    try await self.albumRepo.setDownloaded(itemId: self.item.uuid, isDownloaded)
                    self.item.isDownloaded = isDownloaded
                case _ where item is Song:
                    try await self.songRepo.setDownloaded(itemId: self.item.uuid, isDownloaded)
                    self.item.isDownloaded = isDownloaded
                default:
                    print("Cannot set item download status - unrecognized type")
            }
        } catch {
            print("Failed to update downloaded status", error)
        }
    }
}

#if DEBUG
struct DownloadButton_Previews: PreviewProvider {
    static var song = Song(uuid: "1", index: 1, name: "asdf", parentId: "1")

    static var previews: some View {
        DownloadButton(item: song)
            .environment(\.albumRepo, .init(store: .albums))
            .environment(\.songRepo, .init(store: .songs))
            .environment(\.mediaRepo, .init(store: .downloadedMedia))
    }
}
#endif
