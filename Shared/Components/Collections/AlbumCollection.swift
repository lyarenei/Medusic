import Defaults
import OSLog
import SwiftUI

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
        LazyVStack(alignment: .leading) {
            Divider()
                .padding(.bottom, 5)

            ForEach(albums) { album in
                HStack(spacing: 0) {
                    NavigationLink {
                        AlbumDetailScreen(for: album.uuid)
                    } label: {
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
                    }
                    .padding(.vertical, 3)

                    Spacer()

                    Image(systemSymbol: .chevronRight)
                        .foregroundColor(.init(UIColor.separator))
                        .padding(.trailing, 10)
                }

                Divider()
                    .padding(.leading, 77)
            }
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
                    AlbumDetailScreen(for: album.uuid)
                } label: {
                    AlbumTileComponent(album: album)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
