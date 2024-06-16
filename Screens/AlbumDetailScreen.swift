import ButtonKit
import OSLog
import SFSafeSymbols
import SwiftUI

struct AlbumDetailScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @EnvironmentObject
    private var player: MusicPlayer

    let album: AlbumDto

    var body: some View {
        let albumSongs = library.songs.filtered(by: .albumId(album.id))
        List {
            albumDetails(album)
                .listRowSeparator(.hidden)
                .padding(.bottom, 20)

            songs(albumSongs)

            runtime(albumSongs.count)
                .padding(.top, 20)
                .listRowSeparator(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .toolbar {
            // TODO: implement
        }
    }

    @ViewBuilder
    private func albumDetails(_ album: AlbumDto) -> some View {
        VStack(alignment: .center, spacing: 10) {
            artworkWithName(album)
            additionalInfo(genre: "Genre", year: "0000")
                .padding(.bottom, 10)

            actions(album)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func artworkWithName(_ album: AlbumDto) -> some View {
        VStack(alignment: .center, spacing: 20) {
            ArtworkComponent(for: album.id)
                .frame(width: 320, height: 320)

            VStack(spacing: 5) {
                Text(album.name)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(album.artistName)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @ViewBuilder
    private func additionalInfo(genre: String, year: String) -> some View {
        let text = [genre, year].filter(\.isNotEmpty).joined(separator: "・")
        Text(text)
            .foregroundStyle(.gray)
            .font(.caption)
    }

    @ViewBuilder
    private func actions(_ album: AlbumDto) -> some View {
        HStack {
            Group {
                // TODO: fix after play button is cleaned up
                PlayButton("Play", item: album)
                    .frame(width: 150, height: 50)

                AsyncButton {
                    let songs = await library.getSongs(for: album)
                    do {
                        try await player.play(songs: songs.shuffled())
                    } catch {
                        Logger.library.warning("Failed to start playback: \(error.localizedDescription)")
                        Alerts.error("Failed to start playback")
                    }
                } label: {
                    Label("Shuffle", systemSymbol: .shuffle)
                        .frame(width: 150, height: 50)
                        .contentShape(Rectangle())
                }
                .disabledWhenLoading()
            }
            .font(.system(size: 18))
            .buttonStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
            .foregroundStyle(Color.accentColor)
        }
    }

    @ViewBuilder
    private func runtime(_ songCount: Int) -> some View {
        let runtime = library.getRuntime(for: album)

        if songCount > 0 {
            Text("\(songCount) songs, \(runtime.minutes) minutes")
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
    }

    @ViewBuilder
    private func songs(_ songs: [SongDto]) -> some View {
        if songs.isNotEmpty {
            songList(of: songs)
        } else {
            ContentUnavailableView {} description: {
                Text("There are no songs in this album")
            }
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private func songList(of songs: [SongDto]) -> some View {
        let discCount = library.getDiscCount(for: album)
        if discCount > 1 {
            ForEach(enumerating: 1...discCount) { discNum in
                let discSongs = songs.filtered(by: .albumDisc(num: discNum))
                Section {
                    songCollection(songs: discSongs.sorted(by: .index))
                } header: {
                    discGroupHeader(text: "Disc \(discNum)")
                }
            }
        } else {
            songCollection(songs: songs.sorted(by: .index))
        }
    }

    // TODO: in progress vvv

    @ViewBuilder
    private func songCollection(songs: [SongDto]) -> some View {
        ForEach(songs) { song in
            HStack(spacing: 10) {
                songCell(allSongs: albumSongs, song)
            }
            .frame(height: 35)
        }
    }

    @ViewBuilder
    private func songCell(allSongs: [SongDto], _ song: SongDto) -> some View {
        SongListRowComponent(song: song)
            .showAlbumOrder()
            .showArtistName()
            .height(35)
            .contentShape(Rectangle())
            .contextMenu { SongContextOptions(song: song) }
            .onTapGesture { Task { await onSongTap(song) } }
    }

    private func onSongTap(_ song: SongDto) async {
        let queue = {
            var songsToPlay: [SongDto] = []
            let currentDiscSongs = albumSongs
                .filtered(by: .albumDisc(num: song.albumDisc))
                .sorted(by: .index)

            let albumDiscCount = library.getDiscCount(for: album)
            var restOfSongs: [SongDto] = []
            for discNum in song.albumDisc...albumDiscCount {
                guard discNum != song.albumDisc else { continue }
                let discSongs = albumSongs.filtered(by: .albumDisc(num: discNum))
                restOfSongs.append(contentsOf: discSongs.sorted(by: .index))
            }

            songsToPlay.append(contentsOf: currentDiscSongs.dropFirst(song.index))
            songsToPlay.append(contentsOf: restOfSongs)
            return songsToPlay
        }()

        do {
            try await player.play(song: song)
        } catch {
            Logger.player.warning("Failed to play song \(song.id): \(error.localizedDescription)")
            Alerts.error("Failed to play song")
            return
        }

        player.enqueue(songs: queue, position: .last)
    }

    @ViewBuilder
    private func discGroupHeader(text: String) -> some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)

            HStack {
                Text(text)
                    .foregroundColor(.gray)
                    .font(.system(size: 16))

                Spacer()
            }
            .padding(.leading)
            .padding(.top)
            .padding(.bottom, 5)
        }
    }

    @ViewBuilder
    private var albumToolbarMenu: some View {
        Menu {
            AlbumContextMenu(album: album)
        } label: {
            Image(systemSymbol: .ellipsisCircle)
                .imageScale(.large)
        }
    }

    private var albumSongs: [SongDto] {
        library.songs.filtered(by: .albumId(album.id))
    }

    private var previewAlbums: [AlbumDto] {
        library.albums.filter { $0.id != album.id && $0.artistId == album.artistId }
    }
}

// MARK: - Context options

private struct SongContextOptions: View {
    let song: SongDto

    var body: some View {
        PlayButton("Play", item: song)
        DownloadSongButton(songId: song.id, isDownloaded: song.isDownloaded)
        FavoriteButton(songId: song.id, isFavorite: song.isFavorite)
        EnqueueButton("Play Next", item: song, position: .next)
        EnqueueButton("Play Last", item: song, position: .last)
    }
}

#if DEBUG
// swiftlint:disable all

#Preview("Default") {
    NavigationStack {
        AlbumDetailScreen(album: PreviewData.albums.first!)
    }
    .environmentObject(PreviewUtils.libraryRepo)
    .environmentObject(ApiClient(previewEnabled: true))
    .environmentObject(PreviewUtils.player)
    .environmentObject(PreviewUtils.fileRepo)
    .environmentObject(PreviewUtils.downloader)
}

#Preview("Empty") {
    NavigationStack {
        AlbumDetailScreen(album: PreviewData.albums.first!)
    }
    .environmentObject(PreviewUtils.libraryRepoEmpty)
    .environmentObject(ApiClient(previewEnabled: true))
    .environmentObject(PreviewUtils.player)
    .environmentObject(PreviewUtils.fileRepo)
    .environmentObject(PreviewUtils.downloader)
}

// swiftlint:enable all
#endif

struct TitleAndIconVerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
            configuration.title
        }
        .multilineTextAlignment(.center)
    }
}
