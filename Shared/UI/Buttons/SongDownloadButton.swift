import SFSafeSymbols
import SwiftUI

struct SongDownloadButton: View {
    @EnvironmentObject
    private var downloader: Downloader

    let song: SongDto

    var body: some View {
        Button {
            if downloader.downloadQueue.contains(song) {
                // TODO: cancel download
            } else if song.isDownloaded {
                Notifier.emitSongDeleteRequested(song.id)
            } else {
                Notifier.emitSongDownloadRequested(song.id)
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
}
