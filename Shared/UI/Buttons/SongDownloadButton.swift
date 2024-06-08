import SFSafeSymbols
import SwiftUI

struct SongDownloadButton: View {
    @EnvironmentObject
    private var downloader: Downloader

    @EnvironmentObject
    private var fileRepo: FileRepository

    let song: SongDto

    var body: some View {
        Button {
            if downloader.downloadQueue.contains(song) {
                // TODO: cancel download
            } else if song.isDownloaded {
                remove()
            } else {
                download()
            }
        } label: {
            if downloader.downloadQueue.contains(song) {
                Label("Cancel download", systemSymbol: .stopCircle)
            } else if song.isDownloaded {
                Label("Remove download", systemSymbol: .trash)
                    .foregroundStyle(.red)
            } else {
                Label("Download", systemSymbol: .icloudAndArrowDown)
            }
        }
    }

    private func download() {
        Task {
            do {
                try await downloader.download(songId: song.id)
            } catch {
                Alerts.error("Download failed", reason: error.localizedDescription)
            }
        }
    }

    private func remove() {
        Task {
            do {
                try await fileRepo.removeFile(for: song.id)
            } catch {
                Alerts.error("Remove failed", reason: error.localizedDescription)
            }
        }
    }
}
