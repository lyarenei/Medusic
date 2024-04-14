import SwiftUI

struct SongCollection: View {
    @EnvironmentObject
    private var player: MusicPlayer

    private var songs: [Song]

    private var showAlbumOrder = false
    private var showArtwork = false
    private var showArtistName = false
    private var showAlbumName = false
    private var showLastDivider = true
    private var type: CollectionType = .list
    private var rowHeight = 40.0

    init(songs: [Song]) {
        self.songs = songs
    }

    var body: some View {
        switch type {
        case .list:
            listContent()
        case .plain:
            plainContent()
        }
    }

    @ViewBuilder
    private func listContent() -> some View {
        ForEach(songs, id: \.id) { song in
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
    private func plainContent() -> some View {
        ForEach(songs, id: \.id) { song in
            HStack(spacing: 10) {
                songInfo(song: song)
                PrimaryActionButton(item: song)
                    .frame(width: rowHeight / 1.5, height: rowHeight / 1.5)
                    .padding(.trailing)
            }
            .frame(height: rowHeight)
            .padding(.leading)

            divider(song: song)
        }
    }

    @ViewBuilder
    private func songInfo(song: Song) -> some View {
        SongListRowComponent(song: song)
            .showArtwork(showArtwork)
            .showArtistName(showArtistName)
            .showAlbumOrder(showAlbumOrder)
            .showAlbumName(showAlbumName)
            .height(rowHeight)
            .contentShape(Rectangle())
            // TODO: handle error
            .onTapGesture { Task { try? await player.play(song: song) } }
            .contextMenu { ContextOptions(song: song) }
    }

    @ViewBuilder
    private func divider(song: Song) -> some View {
        if let lastSong = songs.last {
            if song != lastSong || showLastDivider {
                Divider()
                    .padding(.leading)
            }
        }
    }

    enum CollectionType {
        case list
        case plain
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

    func showAlbumName(_ value: Bool = true) -> SongCollection {
        var view = self
        view.showAlbumName = value
        return view
    }

    func showLastDivider(_ value: Bool = true) -> SongCollection {
        var view = self
        view.showLastDivider = value
        return view
    }
}

#if DEBUG
struct SongCollection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SongCollection(songs: PreviewData.songs)
                .showArtistName()
                .showArtwork()
                .collectionType(.list)
        }
        .environmentObject(PreviewUtils.player)
        .previewDisplayName("List")
        .listStyle(.plain)

        ScrollView {
            VStack {
                SongCollection(songs: PreviewData.songs)
                    .showArtistName()
                    .showArtwork()
                    .collectionType(.plain)
            }
        }
        .environmentObject(PreviewUtils.player)
        .previewDisplayName("VStack")

        ScrollView {
            VStack {
                SongCollection(songs: PreviewData.songs)
                    .showArtistName()
                    .showAlbumOrder()
                    .collectionType(.plain)
            }
        }
        .environmentObject(PreviewUtils.player)
        .previewDisplayName("VStack + order")
    }
}
#endif

private struct ContextOptions: View {
    let song: Song

    var body: some View {
        PlayButton("Play", item: song)
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

        EnqueueButton("Play Next", item: song, position: .next)
        EnqueueButton("Play Last", item: song, position: .last)
    }
}
