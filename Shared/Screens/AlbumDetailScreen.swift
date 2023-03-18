import Kingfisher
import SFSafeSymbols
import SwiftUI
import SwiftUIBackports

private struct AlbumHeading: View {
    var album: Album

    var body: some View {
        VStack {
            ArtworkComponent(itemId: album.id)
                .frame(width: 230, height: 230)

            Text(album.name)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text(album.artistName)
                .font(.title2)
                .multilineTextAlignment(.center)
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

private struct AlbumActions: View {
    var body: some View {
        HStack {
            Button {
                // Album play action
            } label: {
                Image(systemSymbol: .playFill)
                Text("Play")
            }
            .frame(width: 120, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
            .disabled(true)

            Button {
                // Album shuffle play action
            } label: {
                Image(systemSymbol: .shuffle)
                Text("Shuffle")
            }
            .frame(width: 120, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
            .disabled(true)
        }
    }
}

private struct SongList: View {
    var songs: [Song]

    var body: some View {
        LazyVStack {
            ForEach(songs) { song in
                SongEntryComponent(
                    song: song,
                    showAlbumOrder: true,
                    showArtwork: false,
                    showActions: true
                )
                .padding(.leading)
                .padding(.trailing)
                .font(.title3)

                Divider()
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            }
        }
    }
}

struct AlbumDetailScreen: View {
    @StateObject
    var songsController = SongsRepository(store: .songs)

    @State
    private var songs: [Song]?

    @State
    var isDownloaded: Bool = false

    @State
    var isFavorite: Bool = false

    var album: Album

    var body: some View {
        ScrollView {
            VStack {
                AlbumHeading(album: album)

                AlbumActions()
                    .padding(.bottom, 30)

                if let albumSongs = songs {
                    SongList(songs: albumSongs)
                        .padding(.bottom, 10)
                } else {
                    ProgressView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(content: {
                FavoriteButton(isFavorite: $isFavorite)
                    .disabled(true)
            })

            ToolbarItem(content: {
                DownloadButton(isDownloaded: $isDownloaded)
                    .disabled(true)
            })
        })
        .onAppear { Task { await self.setSongs(albumId: album.uuid)}}
        .backport.refreshable { await self.refresh(albumId: album.uuid) }
    }

    private func setSongs(albumId: String) async {
        self.songs = await songsController.getSongs(ofAlbum: albumId)
    }

    private func refresh(albumId: String) async {
        defer { Task { await self.setSongs(albumId: albumId) }}
        self.songs = nil
        do {
            // TODO only pull data for songs of this album
            try await songsController.refresh()
        } catch {
            print("Failed to refresh the songs", error)
        }
    }
}

#if DEBUG
struct AlbumDetailScreen_Previews: PreviewProvider {
    static let album = Album(
        uuid: "abc",
        name: "Album name",
        artistName: "Artist name",
        isFavorite: true
    )

    static let albumLong = Album(
        uuid: "xyz",
        name: "Very long album name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
        artistName: "Very long artist name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
        isFavorite: true
    )

    static var previews: some View {
        AlbumDetailScreen(album: album)
        AlbumDetailScreen(album: albumLong)
    }
}
#endif
