import SwiftUI
import Kingfisher

struct AlbumTile: View {

    var albumImageUrl: URL?
    var albumName: String
    var artistName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            KFImage(albumImageUrl)
                .resizable()
                .frame(width: 160.0, height: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(style: StrokeStyle(lineWidth: 1.0))
                )
            VStack(alignment: .leading) {
                Text(albumName)
                    .font(.subheadline)
                
                Text(artistName)
                    .font(.caption)
            }
        }
    }
}

#if DEBUG
struct AlbumTile_Previews: PreviewProvider {
    static var previews: some View {
        AlbumTile(albumName: "Album name", artistName: "Artist name")
    }
}
#endif
