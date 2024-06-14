import ButtonKit
import SFSafeSymbols
import SwiftUI

struct DownloadAlbumButton: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @EnvironmentObject
    private var fileRepo: FileRepository

    @EnvironmentObject
    private var downloader: Downloader

    @State
    var isDownloaded: Bool

    let albumId: String

    init(albumId: String, isDownloaded: Bool) {
        self.albumId = albumId
        self.isDownloaded = isDownloaded
    }

    var body: some View {
        let albumSongs = library.songs.filtered(by: .albumId(albumId))
        let albumSongIds = albumSongs.map(\.id)
        let isInQueue = !Set(downloader.downloadQueue.map(\.id)).intersection(Set(albumSongIds)).isEmpty
        AsyncButton {
            do {
                if isInQueue {
                    try await cancelAction(albumSongIds)
                } else if isDownloaded {
                    try await removeAction(albumSongIds)
                } else {
                    try await downloadAction(albumSongs.filter { !$0.isDownloaded }.map(\.id))
                }
            } catch let error as MedusicError {
                Alerts.error(error)
            } catch {
                Alerts.error("Action failed")
            }
        } label: {
            Group {
                if isInQueue {
                    Label("Cancel download", systemSymbol: .stopCircle)
                } else if isDownloaded {
                    Label("Remove download", systemSymbol: .trash)
                        .foregroundStyle(.red)
                } else {
                    Label("Download", systemSymbol: .icloudAndArrowDown)
                }
            }
            .scaledToFit()
            .contentTransition(.symbolEffect(.replace))
        }
        .onReceive(NotificationCenter.default.publisher(for: .AlbumDownloaded)) { event in
            guard let data = event.userInfo,
                  let albumId = data["albumId"] as? String,
                  self.albumId == albumId
            else { return }

            isDownloaded = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .SongFileDeleted)) { event in
            // This is strictly not necessary as file removal is immediate unlike downloading.
            guard let data = event.userInfo,
                  let songId = data["songId"] as? String
            else { return }

            if library.songs.filtered(by: .albumId(albumId)).map(\.id).contains(songId) {
                isDownloaded = false
            }
        }
    }

    private func cancelAction(_ songIds: [String]) async throws {
        for songId in songIds {
            // TODO: think about best effort (continue after exception)
            try await downloader.cancelDownload(songId: songId)
        }
    }

    private func removeAction(_ songIds: [String]) async throws {
        for songId in songIds {
            // TODO: think about best effort (continue after exception)
            try await fileRepo.removeFile(for: songId)
        }
    }

    private func downloadAction(_ songIds: [String]) async throws {
        // TODO: think about best effort (continue after exception)
        try await downloader.download(songIds: songIds, startImmediately: true)
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    DownloadSongButton(
        songId: PreviewData.song.id,
        isDownloaded: PreviewData.song.isDownloaded,
        library: PreviewUtils.libraryRepo,
        fileRepo: PreviewUtils.fileRepo
    )
    .environmentObject(PreviewUtils.downloader)
}

// swiftlint:enable all
#endif
