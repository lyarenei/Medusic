import ButtonKit
import SFSafeSymbols
import SwiftUI

struct DownloadSongButton: View {
    @EnvironmentObject
    private var downloader: Downloader

    @State
    var isDownloaded = false

    let itemId: String

    let downloadAction: (String, Bool) async throws -> Void
    let removeAction: (String) async throws -> Void
    let cancelAction: (String) async throws -> Void

    init(
        songId: String,
        isDownloaded: Bool,
        library: LibraryRepository = .shared,
        fileRepo: FileRepository = .shared,
        downloader: Downloader = .shared
    ) {
        self.itemId = songId
        self.isDownloaded = isDownloaded
        self.downloadAction = downloader.download(songId:startImmediately:)
        self.removeAction = fileRepo.removeFile(for:)
        self.cancelAction = downloader.cancelDownload(songId:)
    }

    var body: some View {
        let isInQueue = downloader.downloadQueue.map(\.id).contains(itemId)
        AsyncButton {
            do {
                if isInQueue {
                    try await cancelAction(itemId)
                } else if isDownloaded {
                    try await removeAction(itemId)
                } else {
                    try await downloadAction(itemId, true)
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
        .onReceive(NotificationCenter.default.publisher(for: .SongFileDownloaded)) { event in
            guard let data = event.userInfo,
                  let songId = data["songId"] as? String,
                  itemId == songId
            else { return }

            isDownloaded = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .SongFileDeleted)) { event in
            // This is strictly not necessary as file removal is immediate unlike downloading.
            guard let data = event.userInfo,
                  let songId = data["songId"] as? String,
                  itemId == songId
            else { return }

            isDownloaded = false
        }
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
