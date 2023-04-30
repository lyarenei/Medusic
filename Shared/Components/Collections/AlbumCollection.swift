import Defaults
import OSLog
import SFSafeSymbols
import SwiftUI

enum AlbumDisplayMode: String, Defaults.Serializable {
    case asList
    case asPlainList
    case asTiles
}

struct AlbumCollection: View {
    @Default(.albumDisplayMode)
    private var displayMode: AlbumDisplayMode

    private let albums: [Album]
    private var forceDisplayMode: AlbumDisplayMode?
    private var showChevron = false
    private var rowHeight = 60.0

    init(albums: [Album]) {
        self.albums = albums
    }

    var body: some View {
        switch forceDisplayMode ?? displayMode {
        case .asList:
            listContent()
        case .asPlainList:
            plainContent()
        case .asTiles:
            tileContent()
        }
    }

    @ViewBuilder
    private func listContent() -> some View {
        ForEach(albums) { album in
            NavigationLink {
                AlbumDetailScreen(for: album)
            } label: {
                albumListEntry(album: album)
            }
        }
    }

    @ViewBuilder
    private func plainContent() -> some View {
        ForEach(albums) { album in
            NavigationLink {
                AlbumDetailScreen(for: album)
            } label: {
                albumPlainEntry(album: album)
                    .padding(.vertical, 1)
                    .contentShape(Rectangle())
            }

            Divider()
        }
    }

    @ViewBuilder
    private func tileContent() -> some View {
        ForEach(albums) { album in
            NavigationLink {
                AlbumDetailScreen(for: album)
            } label: {
                AlbumTileComponent(album: album)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func albumListEntry(album: Album) -> some View {
        HStack(spacing: 17) {
            ArtworkComponent(itemId: album.id)
                .frame(width: rowHeight, height: rowHeight)

            albumNameArtist(album: album)
        }
    }

    @ViewBuilder
    private func albumNameArtist(album: Album) -> some View {
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

    @ViewBuilder
    private func albumPlainEntry(album: Album) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 17) {
                ArtworkComponent(itemId: album.id)
                    .frame(width: rowHeight, height: rowHeight)

                albumNameArtist(album: album)
            }

            Spacer()

            if showChevron {
                Image(systemSymbol: .chevronRight)
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
        }
    }
}

extension AlbumCollection {
    func forceMode(_ mode: AlbumDisplayMode) -> AlbumCollection {
        var view = self
        view.forceDisplayMode = mode
        return view
    }

    func rowHeight(_ height: CGFloat) -> AlbumCollection {
        var view = self
        view.rowHeight = height
        return view
    }

    func showNavChevron(_ value: Bool = false) -> AlbumCollection {
        var view = self
        view.showChevron = value
        return view
    }
}

#if DEBUG
struct AlbumList_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AlbumCollection(albums: PreviewData.albums)
                .forceMode(.asList)
        }
        .previewDisplayName("List")

        VStack {
            AlbumCollection(albums: PreviewData.albums)
                .forceMode(.asPlainList)
        }
        .previewDisplayName("Vstack")
        .padding(.horizontal)

        VStack {
            AlbumCollection(albums: PreviewData.albums)
                .forceMode(.asTiles)
        }
        .previewDisplayName("Tiles")
    }
}
#endif
