import SwiftUI
import Kingfisher

struct AlbumTile: View {

    var album: Album

    var body: some View {
        VStack(alignment: .leading) {
            ArtworkComponent(itemId: album.id)

            VStack(alignment: .leading) {
                Text(album.name)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(album.artistName)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
    }
}

#if DEBUG
struct AlbumTile_Previews: PreviewProvider {
    static var album = Album(uuid: "1234", name: "Album name", artistName: "Artist name", isDownloaded: false, isLiked: true)

    static var previews: some View {
        AlbumTile(album: album)
            .environment(\.api, .preview)
    }
}
#endif
