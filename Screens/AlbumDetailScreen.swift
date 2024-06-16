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
            AlbumDetails(album: album)
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .padding(.bottom, 20)

            songs(albumSongs)

            runtime(albumSongs.count)
                .padding(.top, 15)
                .listRowSeparator(.hidden)

            let moreAlbums = library.albums.filter { $0.id != album.id && $0.artistId == album.artistId }
            moreByArtist(moreAlbums)
                .padding(.bottom)
                .listSectionSeparator(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .toolbar {
            // TODO: implement
        }
    }

    @ViewBuilder
    private func runtime(_ songCount: Int) -> some View {
        if songCount > 0 {
            let runtime = library.getRuntime(for: album)
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
                    Text("Disc \(discNum)")
                }
            }
        } else {
            songCollection(songs: songs.sorted(by: .index))
        }
    }

    @ViewBuilder
    private func songCollection(songs: [SongDto]) -> some View {
        ForEach(songs) { song in
            let artistName = album.artistName == song.artistCreditName ? "" : song.artistCreditName
            NewSongListRowComponent(for: song, subtitle: artistName) { song in
                DownloadSongButton(songId: song.id, isDownloaded: song.isDownloaded)
                Divider()
                PlayButton("Play", item: song)
                EnqueueButton("Play next", item: song, position: .next)
                EnqueueButton("Play last", item: song, position: .last)
                Divider()
                FavoriteButton(songId: song.id, isFavorite: song.isFavorite)
            }
            .frame(height: 40)
        }
    }

    private func onSongTap(_ song: SongDto) async {
        let restOfSongs = library.songs
            .filtered(by: .albumId(album.id))
            .sorted(by: .index)
            .drop { $0.index <= song.index }

        do {
            try await player.play(song: song)
        } catch {
            Logger.player.warning("Failed to play song \(song.id): \(error.localizedDescription)")
            Alerts.error("Failed to play song")
            return
        }

        player.enqueue(songs: Array(restOfSongs), position: .last)
    }

    @ViewBuilder
    private func moreByArtist(_ albums: [AlbumDto]) -> some View {
        ItemPreviewCollection(
            "More by \(album.artistName)",
            items: albums
        ) { album in
            NavigationLink {
                AlbumDetailScreen(album: album)
            } label: {
                TileComponent(item: album)
                    .padding(.bottom)
            }
            .foregroundStyle(Color.primary)
        } viewAll: { _ in
            ContentUnavailableView {
                Text("Not available yet")
            }
        }
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

private struct AlbumDetails: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @EnvironmentObject
    private var player: MusicPlayer

    let album: AlbumDto

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            artworkWithName
            additionalInfo(genre: "Genre", year: "0000")
                .padding(.bottom, 10)

            actions
        }
    }

    @ViewBuilder
    private var artworkWithName: some View {
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
    private var actions: some View {
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
}
