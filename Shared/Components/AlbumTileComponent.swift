import SwiftUI
import Kingfisher

struct AlbumTileComponent: View {
    @EnvironmentObject
    private var library: LibraryRepository

    let album: Album

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ArtworkComponent(itemId: album.id)
                .frame(height: 160)

            VStack(alignment: .leading) {
                Text(album.name)
                    .fontWeight(.medium)
                    .font(.subheadline)
                    .lineLimit(1)

                Text(library.getArtistName(for: album))
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, 2)
        }
        .frame(width: 160)
    }
}

#if DEBUG
struct AlbumTile_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next force_unwrapping
        AlbumTileComponent(album: PreviewData.albums.first!)
            .environmentObject(PreviewUtils.libraryRepo)
    }
}
#endif
