import SwiftUI

struct AlbumContextMenu: View {
    let album: Album

    var body: some View {
        PlayButton(text: "Play", item: album)
        DownloadButton(item: album, textDownload: "Download", textRemove: "Remove")
        EnqueueButton(text: "Play Next", item: album, position: .next)
        EnqueueButton(text: "Play Last", item: album, position: .last)
        FavoriteButton(item: album, textFavorite: "Favorite", textUnfavorite: "Unfavorite")
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
