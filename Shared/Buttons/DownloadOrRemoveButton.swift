import ButtonKit
import SFSafeSymbols
import SwiftData
import SwiftUI

struct DownloadOrRemoveButton: View {
    @Environment(\.modelContext)
    private var ctx: ModelContext

    @State
    private var isDownloaded: Bool

    private let itemId: PersistentIdentifier
    private let downloader: Downloader
    private let fileRepo: FileRepository

    init(
        for itemId: PersistentIdentifier,
        isDownloaded: Bool,
        downloader: Downloader = .shared,
        fileRepo: FileRepository = .shared
    ) {
        self.itemId = itemId
        self.isDownloaded = isDownloaded
        self.downloader = downloader
        self.fileRepo = fileRepo
    }

    var body: some View {
        button
            .onReceive(NotificationCenter.default.publisher(for: .SongFileDownloaded)) { event in
                guard let data = event.userInfo,
                      let eventSong = data["song"] as? SongDto
                else { return }

                if let song = ctx.model(for: itemId) as? Song,
                   song.jellyfinId == eventSong.id {
                    withAnimation { isDownloaded = true }

                    // TODO: Move to data manager
                    song.isDownloaded = true
                    try? ctx.save()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .SongFileDeleted)) { event in
                guard let data = event.userInfo,
                      let eventSong = data["song"] as? SongDto
                else { return }

                if let song = ctx.model(for: itemId) as? Song,
                   song.jellyfinId == eventSong.id {
                    withAnimation { isDownloaded = false }

                    // TODO: Move to data manager
                    song.isDownloaded = false
                    try? ctx.save()
                }
            }
    }

    @ViewBuilder
    private var button: some View {
        AsyncButton {
            await action()
        } label: {
            let text = isDownloaded ? "Remove" : "Download"
            let symbol: SFSymbol = isDownloaded ? .trash : .icloudAndArrowDown
            Label(text, systemSymbol: symbol)
                .contentTransition(.symbolEffect(.replace))
        }
    }

    private func action() async {
        guard let song = ctx.model(for: itemId) as? Song else { return }
        do {
            if isDownloaded {
                return try await fileRepo.removeFile(for: song.jellyfinId)
            }

            try await downloader.download(song.jellyfinId)
        } catch {
            if isDownloaded {
                Alerts.error("Failed to remove file")
                return
            }

            Alerts.error("Failed to download song")
        }
    }
}
