import Defaults
import SwiftUI

struct AlbumList: View {
    @Default(.albumDisplayMode)
    private var albumDisplayMode: AlbumDisplayMode

    var albums: [Album]?

    var body: some View {
        if let gotAlbums = albums, gotAlbums.isEmpty {
            Text("No albums")
                .font(.title3)
                .foregroundColor(Color(UIColor.secondaryLabel))
        } else if let gotAlbums = albums {
            switch albumDisplayMode {
            case .asList:
                    ListOfAlbums(albums: gotAlbums)
            default:
                ScrollView(.vertical) {
                    AlbumTileList(albums: albums)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
            }
        } else {
            ProgressView()
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
        AlbumList(albums: nil)
        AlbumList(albums: [])
        AlbumList(albums: albums)
    }
}
#endif

private struct ListOfAlbums: View {
    var albums: [Album]

    var body: some View {
        // Note: list is not lazy on macOS < 13: https://stackoverflow.com/q/72070486
        List(albums) { album in
            NavigationLink {
                AlbumDetailScreen(for: album.uuid)
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

private struct AlbumTileList: View {
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
                        AlbumDetailScreen(for: album.uuid)
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
