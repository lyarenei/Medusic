import Defaults
import OSLog
import SFSafeSymbols
import SwiftUI

enum AlbumDisplayMode: String, Defaults.Serializable {
    case asList
    case asTiles
}

struct AlbumCollection: View {
    @Default(.albumDisplayMode)
    var displayMode: AlbumDisplayMode

    private var albums: [Album]?
    private let overrideDisplayMode: AlbumDisplayMode?

    init(
        albums: [Album]?,
        overrideDisplayMode: AlbumDisplayMode? = nil
    ) {
        self.albums = albums
        self.overrideDisplayMode = overrideDisplayMode
    }

    var body: some View {
        if let gotAlbums = albums, gotAlbums.isEmpty {
            Text("No albums available")
                .font(.title3)
                .foregroundColor(.gray)
        } else if let gotAlbums = albums {
            switch overrideDisplayMode ?? displayMode {
            case .asList:
                AlbumList(albums: gotAlbums)
            default:
                AlbumTileList(albums: gotAlbums)
            }
        } else {
            InProgressComponent("Refreshing albums ...")
        }
    }
}

#if DEBUG
struct AlbumList_Previews: PreviewProvider {
    static var previews: some View {
        AlbumCollection(albums: PreviewData.albums)
            .padding([.leading, .trailing])
        AlbumCollection(albums: PreviewData.albums, overrideDisplayMode: .asList)
            .padding([.leading, .trailing])
        AlbumCollection(albums: [])
        AlbumCollection(albums: nil)
    }
}
#endif

private struct AlbumList: View {
    var albums: [Album]

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 3) {
            Divider()
                .padding(.bottom, 5)

            ForEach(albums) { album in
                NavigationLink {
                    AlbumDetailScreen(for: album)
                } label: {
                    AlbumListItem(album: album)
                        .padding(.vertical, 3)
                        .contentShape(Rectangle())
                }

                Divider()
                    .padding(.leading, 77)
            }
        }
    }
}

private struct AlbumListItem: View {
    let album: Album

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 17) {
                ArtworkComponent(itemId: album.id)
                    .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 3) {
                    Text(album.name)
                        .font(.title2)
                        .lineLimit(1)

                    Text(album.artistName)
                        .lineLimit(1)
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemSymbol: .chevronRight)
                .foregroundColor(.init(UIColor.separator))
                .padding(.trailing, 10)
        }
    }
}

private struct AlbumTileList: View {
    var albums: [Album]

    var body: some View {
        let layout = [GridItem(.flexible()), GridItem(.flexible())]
        LazyVGrid(columns: layout) {
            ForEach(albums) { album in
                NavigationLink {
                    AlbumDetailScreen(for: album)
                } label: {
                    AlbumTileComponent(album: album)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
