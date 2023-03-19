import SwiftUI

struct AlbumList: View {
    var albums: [Album]?

    var body: some View {
        if let gotAlbums = albums, gotAlbums.isEmpty {
            Text("No albums")
                .font(.title3)
                .foregroundColor(Color(UIColor.secondaryLabel))
        } else if let gotAlbums = albums {
            ListOfAlbums(albums: gotAlbums)
                .listStyle(.plain)
        } else {
            ProgressView()
        }
    }
}

private struct ListOfAlbums: View {
    var albums: [Album]

    var body: some View {
        // Note: list is not lazy on macOS < 13: https://stackoverflow.com/q/72070486
        List(albums) { album in
            NavigationLink {
                AlbumDetailScreen(album: album)
            } label: {
                HStack(spacing: 25) {
                    ArtworkComponent(itemId: album.id)
                        .frame(width: 50, height: 50)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(album.name)
                            .lineLimit(1)
                            .font(.title2)

                        Text(album.artistName)
                            .lineLimit(1)
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
            }
        }
    }
}

#if DEBUG
struct AlbumList_Previews: PreviewProvider {
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
        AlbumList(albums: albums)
    }
}
#endif
