import ButtonKit
import OSLog
import SFSafeSymbols
import SwiftUI

struct DownloadsScreen: View {
    @EnvironmentObject
    private var downloader: Downloader

    @EnvironmentObject
    private var fileRepo: FileRepository

    @EnvironmentObject
    private var repo: LibraryRepository

    private let logger: Logger = .library

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Downloads")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) { removeAllButton }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        let downloadedSongs = repo.songs.filtered(by: .downloaded)
        List {
            Section {
                NavigationLink {
                    if downloader.downloadQueue.isNotEmpty {
                        downloadQueueList
                    } else {
                        ContentUnavailableView(
                            "No active downloads",
                            systemImage: "",
                            description: Text("Any songs currently being downloaded will appear here.")
                        )
                    }
                } label: {
                    LabeledContent("Download queue", value: "\(downloader.downloadQueue.count)")
                }
                .disabled(downloader.downloadQueue.isEmpty)
            }

            if downloadedSongs.isNotEmpty {
                Section("Downloaded songs") {
                    ForEach(downloadedSongs) { song in
                        HStack {
                            SongListRowComponent(song: song)
                                .showArtwork()
                                .showArtistName()

                            Spacer()
                            DownloadButton(item: song)
                                .buttonStyle(.plain)
                                .foregroundStyle(Color.accentColor)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) { removeSongButton(for: song) }
                    }
                }
                .textCase(nil)
            }
        }
        .listStyle(.grouped)
    }

    @ViewBuilder
    private func removeSongButton(for song: SongDto) -> some View {
        AsyncButton(role: .destructive) {
            do {
                try await fileRepo.removeFile(for: song.id)
            } catch {
                logger.warning("Song removal failed: \(error.localizedDescription)")
                Alerts.error("Remove failed")
            }
        } label: {
            Label("Remove", systemSymbol: .trash)
        }
        .disabledWhenLoading()
    }

    @ViewBuilder
    private var removeAllButton: some View {
        AsyncButton("Remove all") {
            do {
                try await fileRepo.removeAllFiles()
            } catch {
                logger.warning("Removing downloaded songs failed: \(error.localizedDescription)")
                Alerts.error("Removing failed")
            }
        }
        .disabledWhenLoading()
    }

    @ViewBuilder
    private var downloadQueueList: some View {
        List(downloader.downloadQueue) { song in
            HStack {
                SongListRowComponent(song: song)
                    .showArtwork()
                    .showArtistName()

                Spacer()
                ProgressView()
            }
            .swipeActions(edge: .leading) {
                Button(role: .destructive) {
                    // TODO: Support for cancelling downloads
                    Alerts.info("Feature is not available")
                } label: {
                    Label("Cancel", systemSymbol: .xmarkApp)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Current downloads")
        .navigationBarTitleDisplayMode(.inline)
    }
}
