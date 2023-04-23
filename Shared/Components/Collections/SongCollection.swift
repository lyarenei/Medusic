import SwiftUI

struct SongCollection: View {
    var songs: [Song]

    let showAlbumOrder: Bool
    let showArtwork: Bool
    let showArtistName: Bool
    let type: CollectionType
    let musicPlayer: MusicPlayer

    init(
        songs: [Song],
        showAlbumOrder: Bool,
        showArtwork: Bool,
        showArtistName: Bool,
        type: CollectionType,
        musicPlayer: MusicPlayer = .shared
    ) {
        self.songs = songs
        self.showAlbumOrder = showAlbumOrder
        self.showArtwork = showArtwork
        self.showArtistName = showArtistName
        self.type = type
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
    func emptyView() -> some View {
        if type == .list {
            empty()
                .hideListRowSeparator()
        } else {
            empty()
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
    }

    @ViewBuilder
    func content() -> some View {
        switch type {
        case .list:
            List { listContent() }
        case .vstack:
            VStack { stackContent() }
        case .lazyVstack:
            LazyVStack { stackContent() }
        }
    }

    @ViewBuilder
    func listContent() -> some View {
        ForEach(songs) { song in
            HStack(spacing: 10) {
                songInfo(song: song)
                PrimaryActionButton(item: song)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.accentColor)
            }
            .frame(height: 40)
        }
    }

    @ViewBuilder
    func stackContent() -> some View {
        ForEach(songs) { song in
            HStack(spacing: 10) {
                songInfo(song: song)
                PrimaryActionButton(item: song)
                    .frame(width: 25, height: 25)
                    .padding(.trailing)
            }
            .frame(height: 40)
            .padding(.leading)

            Divider()
                .padding(.leading)
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
        .contentShape(Rectangle())
        .onTapGesture {
            Task { await musicPlayer.play(song: song) }
        }
        .contextMenu { ContextOptions(song: song) }
    }

    enum CollectionType {
        case list
        case vstack
        case lazyVstack
    }
}

#if DEBUG
struct SongCollection_Previews: PreviewProvider {
    static var previews: some View {
        SongCollection(
            songs: PreviewData.songs,
            showAlbumOrder: false,
            showArtwork: true,
            showArtistName: true,
            type: .list
        )
        .previewDisplayName("List")

        SongCollection(
            songs: PreviewData.songs,
            showAlbumOrder: false,
            showArtwork: true,
            showArtistName: true,
            type: .vstack
        )
        .previewDisplayName("VStack")

        SongCollection(
            songs: [],
            showAlbumOrder: false,
            showArtwork: true,
            showArtistName: true,
            type: .list
        )
        .previewDisplayName("Empty list")

        SongCollection(
            songs: [],
            showAlbumOrder: false,
            showArtwork: true,
            showArtistName: true,
            type: .vstack
        )
        .previewDisplayName("Empty stack")
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
