import ButtonKit
import OSLog
import SFSafeSymbols
import SwiftUI

struct AlbumDetailScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @EnvironmentObject
    private var player: MusicPlayer

    let album: Album

    var body: some View {
        ScrollView {
            content
                .padding(.top, 15)
                .padding(.bottom, 25)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                albumToolbarMenu
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                RefreshButton(mode: .album(id: album.id))
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack {
            artworkWithName
                .padding(.bottom, 10)

            actions
                .padding(.bottom, 10)

            runtime

            songs(albumSongs)
                .padding(.bottom, 15)

            if previewAlbums.isNotEmpty {
                AlbumPreviewCollection(
                    for: previewAlbums,
                    titleText: "More by \(album.artistName)",
                    emptyText: "No albums"
                )
                .stackType(.horizontal)
            }
        }
    }

    @ViewBuilder
    private var artworkWithName: some View {
        VStack(spacing: 20) {
            ArtworkComponent(for: album)
                .frame(width: 270, height: 270)

            VStack(spacing: 5) {
                Text(album.name)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(album.artistName)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var actions: some View {
        HStack {
            PlayButton("Play", item: album)
                .frame(width: 120, height: 45)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 1.0))
                        .foregroundColor(.accentColor)
                )

            AsyncButton {
                let songs = library.getSongs(for: album)
                do {
                    try await player.play(songs: songs.shuffled())
                } catch {
                    Logger.library.warning("Failed to start playback: \(error.localizedDescription)")
                    Alerts.error("Failed to start playback")
                }
            } label: {
                Label("Shuffle", systemSymbol: .shuffle)
            }
            .frame(width: 120, height: 45)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
                    .foregroundColor(.accentColor)
            )
        }
    }

    @ViewBuilder
    private var runtime: some View {
        let songCount = library.getSongs(for: album).count
        let runtime = library.getRuntime(for: album)

        if songCount > 0 {
            Text("\(songCount) songs, \(runtime.minutes) minutes")
                .foregroundColor(.gray)
                .font(.system(size: 16))
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func songs(_ songs: [Song]) -> some View {
        VStack {
            if songs.isEmpty {
                Text("No songs")
                    .foregroundColor(.gray)
                    .font(.title3)
            } else {
                songList(of: songs)
            }
        }
    }

    @ViewBuilder
    private func songList(of songs: [Song]) -> some View {
        let discCount = library.getDiscCount(for: album)
        if discCount > 1 {
            ForEach(enumerating: 1...discCount) { discNum in
                let discSongs = songs.filtered(by: .albumDisc(num: discNum))
                Section {
                    songCollection(
                        songs: discSongs.sorted(by: .index),
                        showLastDivider: discNum == discCount
                    )
                } header: {
                    discGroupHeader(text: "Disc \(discNum)")
                }
            }
        } else {
            Divider()
                .padding(.leading)

            songCollection(
                songs: songs.sorted(by: .index),
                showLastDivider: true
            )
        }
    }

    @ViewBuilder
    private func songCollection(songs: [Song], showLastDivider: Bool) -> some View {
        ForEach(songs, id: \.id) { song in
            HStack(spacing: 10) {
                songCell(allSongs: albumSongs, song)
                PrimaryActionButton(item: song)
                    .padding(.trailing)
            }
            .frame(height: 35)
            .padding(.leading)

            divider(songs: songs, song: song, showLastDivider: showLastDivider)
        }
    }

    @ViewBuilder
    private func songCell(allSongs: [Song], _ song: Song) -> some View {
        SongListRowComponent(song: song)
            .showAlbumOrder()
            .showArtistName()
            .height(35)
            .contentShape(Rectangle())
            .contextMenu { SongContextOptions(song: song) }
            .onTapGesture { Task { await onSongTap(song) } }
    }

    private func onSongTap(_ song: Song) async {
        let queue = {
            var songsToPlay: [Song] = []
            let currentDiscSongs = albumSongs
                .filtered(by: .albumDisc(num: song.albumDisc))
                .sorted(by: .index)

            let albumDiscCount = library.getDiscCount(for: album)
            var restOfSongs: [Song] = []
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
    private func divider(songs: [Song], song: Song, showLastDivider: Bool) -> some View {
        if let lastSong = songs.last {
            if song != lastSong || showLastDivider {
                Divider()
                    .padding(.leading)
            }
        }
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

    private var albumSongs: [Song] {
        library.songs.filtered(by: .albumId(album.id))
    }

    private var previewAlbums: [Album] {
        library.albums.filter { $0.id != album.id && $0.artistId == album.artistId }
    }
}

// MARK: - Context options

private struct SongContextOptions: View {
    let song: Song

    var body: some View {
        PlayButton("Play", item: song)
        DownloadButton(item: song, textDownload: "Download", textRemove: "Remove")
        FavoriteButton(item: song, textFavorite: "Favorite", textUnfavorite: "Unfavorite")
        EnqueueButton("Play Next", item: song, position: .next)
        EnqueueButton("Play Last", item: song, position: .last)
    }
}

#if DEBUG
// swiftlint:disable all

#Preview("Default") {
    NavigationView {
        AlbumDetailScreen(album: PreviewData.albums.first!)
    }
    .previewDisplayName("Default")
    .environmentObject(PreviewUtils.libraryRepo)
    .environmentObject(ApiClient(previewEnabled: true))
    .environmentObject(PreviewUtils.player)
}

#Preview("Empty") {
    AlbumDetailScreen(album: PreviewData.albums.first!)
        .previewDisplayName("Empty")
        .environmentObject(PreviewUtils.libraryRepoEmpty)
        .environmentObject(ApiClient(previewEnabled: true))
        .environmentObject(PreviewUtils.player)
}

// swiftlint:enable all
#endif
