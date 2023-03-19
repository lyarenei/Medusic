import SwiftUI

struct AlbumTileList: View {
    var albums: [Album]?

    var body: some View {
        let layout = [GridItem(.flexible()), GridItem(.flexible())]
        if let gotAlbums = albums, gotAlbums.isEmpty {
            Text("No albums")
                .font(.title3)
                .foregroundColor(Color(UIColor.secondaryLabel))
        } else if let gotAlbums = albums {
            LazyVGrid(columns: layout) {
                ForEach(gotAlbums) { album in
                    NavigationLink {
                        AlbumDetailScreen(album: album)
                    } label: {
                        AlbumTileComponent(album: album)
                    }
                    .buttonStyle(.plain)
                }
            }
        } else {
            ProgressView()
        }
    }
}

#if DEBUG
struct AlbumTileList_Previews: PreviewProvider {
    static var albums: [Album] = [
        Album(
            uuid: "1",
            name: "Nice album name",
            artistName: "Album artist",
            isFavorite: true
        ),
        Album(
            uuid: "2",
            name: "Album with very long name that one gets tired reading it",
            artistName: "Unamusing artist",
            isDownloaded: true
        ),
    ]

    static var previews: some View {
        AlbumTileList(albums: albums)
        AlbumTileList(albums: [])
        AlbumTileList(albums: nil)
    }
}
#endif
