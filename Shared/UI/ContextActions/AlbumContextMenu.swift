import SwiftUI

struct AlbumContextMenu: View {
    let album: AlbumDto

    var body: some View {
        PlayButton("Play", item: album)
        DownloadButton(item: album, textDownload: "Download", textRemove: "Remove")
        EnqueueButton("Play Next", item: album, position: .next)
        EnqueueButton("Play Last", item: album, position: .last)
        FavoriteButton(songId: album.id, isFavorite: album.isFavorite)
    }
}

#if DEBUG
// swiftlint:disable all
struct AlbumContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        AlbumContextMenu(album: PreviewData.albums.first!)
    }
}
// swiftlint:enable all
#endif
