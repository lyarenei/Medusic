import SwiftUI
import Kingfisher

struct AlbumTileComponent: View {

    var album: Album

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ArtworkComponent(itemId: album.id)
                .frame(height: 160)

            VStack(alignment: .leading) {
                Text(album.name)
                    .fontWeight(.medium)
                    .font(.subheadline)
                    .lineLimit(1)

                Text(album.artistName)
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
    static var album = Album(uuid: "1234", name: "Beautiful album name", artistName: "Loong Loong maaaaaaaanrgagr", isDownloaded: false, isLiked: true)

    static var previews: some View {
        AlbumTileComponent(album: album)
            .environment(\.api, .preview)
    }
}
#endif
