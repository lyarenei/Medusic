import SwiftUI

struct SongCollection: View {
    var songs: [Song]

    let showAlbumOrder: Bool
    let showArtwork: Bool
    let showArtistName: Bool

    var musicPlayer: MusicPlayer

    init(
        songs: [Song],
        showAlbumOrder: Bool,
        showArtwork: Bool,
        showArtistName: Bool,
        musicPlayer: MusicPlayer = .shared
    ) {
        self.songs = songs
        self.showAlbumOrder = showAlbumOrder
        self.showArtwork = showArtwork
        self.showArtistName = showArtistName
        self.musicPlayer = musicPlayer
    }

    var body: some View {
        if songs.isEmpty {
            empty()
        } else {
            content()
        }
    }

    @ViewBuilder
    func empty() -> some View {
        HStack {
            Spacer()

            Text("No songs available")
                .font(.title3)
                .foregroundColor(.gray)

            Spacer()
        }
        .hideListRowSeparator()
    }

    @ViewBuilder
    func content() -> some View {
        ForEach(songs) { song in
            HStack(spacing: 10) {
                songInfo(song: song)
                PrimaryActionButton(item: song)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.accentColor)
            }
            .frame(height: 45)
        }
    }

    @ViewBuilder
    func songInfo(song: Song) -> some View {
        SongListRowComponent(
            song: song,
            showAlbumOrder: showAlbumOrder,
            showArtwork: showArtwork,
            showArtistName: showArtistName
        )
        .onTapGesture {
            Task { await musicPlayer.play(song: song) }
        }
        .contextMenu { ContextOptions(song: song) }
    }
}

#if DEBUG
struct SongCollection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SongCollection(
                songs: PreviewData.songs,
                showAlbumOrder: false,
                showArtwork: true,
                showArtistName: true
            )
        }
        .previewDisplayName("Default")

        List {
            SongCollection(
                songs: [],
                showAlbumOrder: false,
                showArtwork: true,
                showArtistName: true
            )
        }
        .previewDisplayName("Empty")
    }
}
#endif

private struct ContextOptions: View {
    let song: Song

    var body: some View {
        PlayButton(text: "Play", item: song)
        DownloadButton(
            item: song,
            textDownload: "Download",
            textRemove: "Remove"
        )

        FavoriteButton(
            item: song,
            textFavorite: "Favorite",
            textUnfavorite: "Unfavorite"
        )

        EnqueueButton(text: "Play Next", item: song, position: .next)
        EnqueueButton(text: "Play Last", item: song, position: .last)
    }
}
