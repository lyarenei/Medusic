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
            AlbumDetails(album: album, albumSongCount: albumSongs.count)
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .padding(.bottom, 20)

            songs(albumSongs)

            runtime(albumSongs.count)
                .padding(.top, 15)
                .listRowSeparator(.hidden)

            let moreAlbums = library.albums.filter { $0.id != album.id && $0.artistId == album.artistId }
            moreByArtist(moreAlbums)
                .listSectionSeparator(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    AlbumMenuOptions(album: album)
                } label: {
                    Image(systemSymbol: .ellipsis)
                        .circleBackground()
                }
            }
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
            let comparison = album.artistName.localizedCaseInsensitiveCompare(song.artistCreditName)
            let artistName = comparison == .orderedSame ? "" : song.artistCreditName
            NewSongListRowComponent(for: song, subtitle: artistName) { song in
                Task { await onSongTap(song) }
            } menuActions: { song in
                SongMenuOptions(song: song)
            }
            .showAlbumIndex()
            .setFonts(titleFont: .body)
            .frame(height: 35)
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
                TileComponent(for: album.id)
                    .tileTitle(album.name)
                    .padding(.bottom)
            }
            .foregroundStyle(Color.primary)
        } viewAll: { allAlbums in
            List(allAlbums) { album in
                AlbumListRow(album: album)
                    .frame(height: 60)
                    .albumContextMenu(for: album)
            }
            .listStyle(.plain)
            .navigationTitle("Albums by \(album.artistName)")
            .navigationBarTitleDisplayMode(.inline)
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
    .environmentObject(PreviewUtils.apiClient)
    .environmentObject(PreviewUtils.player)
    .environmentObject(PreviewUtils.fileRepo)
    .environmentObject(PreviewUtils.downloader)
}

#Preview("Empty") {
    NavigationStack {
        AlbumDetailScreen(album: PreviewData.albums.first!)
    }
    .environmentObject(PreviewUtils.libraryRepoEmpty)
    .environmentObject(PreviewUtils.apiClient)
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
    let albumSongCount: Int

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            artworkWithName
            additionalInfo(genre: album.genre, year: album.releaseYear)
                .padding(.bottom, 10)

            actions
                .disabled(albumSongCount < 1)
        }
    }

    @ViewBuilder
    private var artworkWithName: some View {
        VStack(alignment: .center, spacing: 20) {
            ArtworkComponent(for: album.id)
                .frame(width: 290, height: 290)

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

struct CircleBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(5)
            .background {
                Circle()
                    .fill(.ultraThickMaterial)
                    .scaledToFill()
            }
    }
}

extension View {
    func circleBackground() -> some View {
        modifier(CircleBackground())
    }
}
