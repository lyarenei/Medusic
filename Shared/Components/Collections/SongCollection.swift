import SwiftUI

struct SongCollection: View {
    var songs: [Song]

    private var showAlbumOrder = false
    private var showArtwork = false
    private var showArtistName = false
    private var type: CollectionType = .list
    private let musicPlayer: MusicPlayer
    private var rowHeight = 40.0

    init(
        songs: [Song],
        musicPlayer: MusicPlayer = .shared
    ) {
        self.songs = songs
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
    private func emptyView() -> some View {
        if type == .list {
            empty()
                .hideListRowSeparator()
        } else {
            empty()
        }
    }

    @ViewBuilder
    private func empty() -> some View {
        HStack {
            Spacer()
            Text("No songs available")
                .font(.title3)
                .foregroundColor(.gray)

            Spacer()
        }
    }

    @ViewBuilder
    private func content() -> some View {
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
    private func listContent() -> some View {
        ForEach(songs) { song in
            HStack(spacing: 10) {
                songInfo(song: song)
                PrimaryActionButton(item: song)
                    .frame(width: rowHeight / 1.5, height: rowHeight / 1.5)
                    .foregroundColor(.accentColor)
            }
            .frame(height: rowHeight)
        }
    }

    @ViewBuilder
    private func stackContent() -> some View {
        ForEach(songs) { song in
            HStack(spacing: 10) {
                songInfo(song: song)
                PrimaryActionButton(item: song)
                    .frame(width: rowHeight / 1.5, height: rowHeight / 1.5)
                    .padding(.trailing)
            }
            .frame(height: rowHeight)
            .padding(.leading)

            Divider()
                .padding(.leading)
        }
    }

    @ViewBuilder
    private func songInfo(song: Song) -> some View {
        SongListRowComponent(song: song)
            .showArtwork(showArtwork)
            .showArtistName(showArtistName)
            .showAlbumOrder(showAlbumOrder)
            .height(rowHeight)
            .contentShape(Rectangle())
            .onTapGesture { Task { await musicPlayer.play(song: song) } }
            .contextMenu { ContextOptions(song: song) }
    }

    enum CollectionType {
        case list
        case vstack
        case lazyVstack
    }
}

extension SongCollection {
    func showAlbumOrder(_ value: Bool = true) -> SongCollection {
        var view = self
        view.showAlbumOrder = value
        return view
    }

    func showArtwork(_ value: Bool = true) -> SongCollection {
        var view = self
        view.showArtwork = value
        return view
    }

    func showArtistName(_ value: Bool = true) -> SongCollection {
        var view = self
        view.showArtistName = value
        return view
    }

    func collectionType(_ type: CollectionType) -> SongCollection {
        var view = self
        view.type = type
        return view
    }

    func rowHeight(_ height: CGFloat) -> SongCollection {
        var view = self
        view.rowHeight = height
        return view
    }
}

#if DEBUG
struct SongCollection_Previews: PreviewProvider {
    static var previews: some View {
        SongCollection(songs: PreviewData.songs)
            .showArtistName()
            .showArtwork()
            .previewDisplayName("List")

        SongCollection(songs: PreviewData.songs)
            .showArtistName()
            .showArtwork()
            .previewDisplayName("VStack")

        SongCollection(songs: [])
            .previewDisplayName("Empty list")

        SongCollection(songs: [])
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
