import Combine
import OSLog
import SFSafeSymbols
import SwiftUI

struct DownloadButton: View {
    @State
    private var isDownloaded = false

    @State
    private var inProgress = false

    @ObservedObject
    private var fileRepo: FileRepository

    private var item: any JellyfinItem
    private var textDownload: String?
    private var textRemove: String?
    private var songRepo: SongRepository
    private var layout: ButtonLayout = .horizontal

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
        button()
            .onAppear { handleOnAppear() }
            .onChange(of: fileRepo.downloadedSongs) { downloaded in
                handleIsDownloaded(downloaded)
            }
            .onChange(of: fileRepo.downloadQueue) { dlq in
                handleInProgress(dlq)
            }
    }

    @ViewBuilder
    private func button() -> some View {
        Button {
            action()
        } label: {
            if inProgress {
                progressIndicator()
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
    private func icon() -> some View {
        Image(systemSymbol: isDownloaded ? .trash : .icloudAndArrowDown)
            .scaledToFit()
    }

    @ViewBuilder
    private func progressIndicator() -> some View {
        ProgressView()
            .scaledToFit()
    }

    @ViewBuilder
    private func hLayout() -> some View {
        HStack {
            icon()
            buttonText(isDownloaded ? textRemove : textDownload)
        }
    }

    @ViewBuilder
    private func vLayout() -> some View {
        VStack {
            icon()
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
            isDownloaded = fileRepo.downloadedSongs.contains { $0 == item }
            inProgress = fileRepo.downloadQueue.contains { $0 == item }
        default:
            isDownloaded = false
            inProgress = false
        }
    }

    private func handleIsDownloaded(_ songs: [Song]) {
        switch item {
        case let item as Song:
            isDownloaded = songs.contains { $0 == item }
        default:
            inProgress = false
        }
    }

    private func handleInProgress(_ songs: [Song]) {
        switch item {
        case let item as Album:
            inProgress = songs.contains { $0.parentId == item.uuid }
        case let item as Song:
            inProgress = songs.contains { $0 == item }
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
                print("Button action failed for item: \(item) - \(error.localizedDescription)")
            }
        }
    }

    private func downloadAction() async throws {
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

    private func removeAction() async throws {
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
struct DownloadButton_Previews: PreviewProvider {
    static var previews: some View {
        DownloadButton(
            item: PreviewData.albums.first!,
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
        .font(.title)
        .previewDisplayName("Icon only")

        DownloadButton(
            item: PreviewData.albums.first!,
            textDownload: "Download",
            textRemove: "Remove",
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
        .setLayout(.horizontal)
        .font(.title)
        .previewDisplayName("Horizontal")

        DownloadButton(
            item: PreviewData.albums.first!,
            textDownload: "Download",
            textRemove: "Remove",
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
        .setLayout(.vertical)
        .font(.title)
        .previewDisplayName("Vertical")
    }
}
// swiftlint:enable all
#endif
