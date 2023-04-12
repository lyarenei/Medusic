import Combine
import OSLog
import SwiftUI

struct DownloadButton: View {
    @State
    var isDownloaded = false

    @State
    var inProgress = false

    var item: any JellyfinItem
    var textDownload: String?
    var textRemove: String?

    var songRepo: SongRepository

    @ObservedObject
    var fileRepo: FileRepository

    init(
        item: any JellyfinItem,
        textDownload: String? = nil,
        textRemove: String? = nil,
        songRepo: SongRepository = .shared,
        fileRepo: FileRepository = .shared
    ) {
        self.item = item
        self.textDownload = textDownload
        self.textRemove = textRemove
        self.songRepo = songRepo
        self._fileRepo = ObservedObject(wrappedValue: fileRepo)
    }

    var body: some View {
        GeometryReader { readerProxy in
            button(proxy: readerProxy)
                .onAppear { handleOnAppear() }
                .onChange(of: fileRepo.downloadedSongs) { downloaded in
                    handleIsDownloaded(downloaded)
                }
                .onChange(of: fileRepo.downloadQueue) { dlq in
                    handleInProgress(dlq)
                }
        }
    }

    @ViewBuilder
    func button(proxy: GeometryProxy) -> some View {
        Button {
            action()
        } label: {
            if inProgress {
                ProgressView()
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height,
                        alignment: .center
                    )
                    .scaledToFit()
            } else {
                DownloadIcon(isDownloaded: $isDownloaded)
                buttonText()
            }
        }
    }

    @ViewBuilder
    func buttonText() -> some View {
        if let textRemove, let textDownload {
            Text(isDownloaded ? textRemove : textDownload)
        }
    }

    func handleOnAppear() {
        switch item {
        case let item as Song:
            isDownloaded = fileRepo.downloadedSongs.contains { $0 == item }
            inProgress = fileRepo.downloadQueue.contains { $0 == item }
        default:
            isDownloaded = false
            inProgress = false
        }
    }

    func handleIsDownloaded(_ songs: [Song]) {
        switch item {
        case let item as Song:
            isDownloaded = songs.contains { $0 == item }
        default:
            inProgress = false
        }
    }

    func handleInProgress(_ songs: [Song]) {
        switch item {
        case let item as Album:
            inProgress = songs.contains { $0.parentId == item.uuid }
        case let item as Song:
            inProgress = songs.contains { $0 == item }
        default:
            inProgress = false
        }
    }

    func action() {
        Task {
            do {
                if isDownloaded {
                    try await removeAction()
                } else {
                    try await downloadAction()
                }
            } catch {
                print("Button action failed for item: \(item) - \(error.localizedDescription)")
            }
        }
    }

    func downloadAction() async throws {
        switch item {
        case let item as Album:
            let songs = await songRepo.getSongs(ofAlbum: item.uuid)
            try await fileRepo.enqueueToDownload(songs: songs)
        case let item as Song:
            try await fileRepo.enqueueToDownload(song: item)
        default:
            print("Unhandled item type: \(item)")
            return
        }
    }

    func removeAction() async throws {
        switch item {
        case let item as Album:
            let songs = await songRepo.getSongs(ofAlbum: item.uuid)
            try await fileRepo.removeFiles(for: songs)
        case let item as Song:
            try await fileRepo.removeFile(for: item)
        default:
            print("Unhandled item type: \(item)")
            return
        }
    }
}

#if DEBUG
// swiftlint:disable all
struct DownloadButton_Previews: PreviewProvider {
    static var previews: some View {
        DownloadButton(
            item: PreviewData.albums.first!,
            textDownload: "Download",
            textRemove: "Remove",
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
    }
}
// swiftlint:enable all
#endif
