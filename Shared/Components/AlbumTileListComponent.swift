import SwiftUI

struct AlbumTileListComponent: View {

    var albums: [Album]

    var body: some View {
        let layout = [GridItem(.flexible()), GridItem(.flexible())]

        if albums.isEmpty {
            Text("No albums")
                .font(.title3)
                .foregroundColor(Color(UIColor.secondaryLabel))
        } else {
            LazyVGrid(columns: layout) {
                ForEach(albums) { album in
                    NavigationLink {
                        AlbumDetailScreen(album: album)
                    } label: {
                        AlbumTileComponent(album: album)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#if DEBUG
struct AlbumTileListComponent_Previews: PreviewProvider {
    static var albums: [Album] = [
        Album(
            uuid: "1",
            name: "Nice album name",
            artistName: "Album artist",
            isDownloaded: false,
            isFavorite: true
        ),
        Album(
            uuid: "2",
            name: "Album with very long name that one gets tired reading it",
            artistName: "Unamusing artist",
            isDownloaded: true,
            isFavorite: false
        ),
    ]

    static var previews: some View {
        AlbumTileListComponent(albums: albums)

        AlbumTileListComponent(albums: [])
    }
}
#endif
