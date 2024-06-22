import SwiftUI

struct AlbumMenuOptions: View {
    let album: AlbumDto

    var body: some View {
        DownloadAlbumButton(albumId: album.id, isDownloaded: album.isDownloaded)
        Divider()
        PlayButton("Play", item: album)
        EnqueueButton("Play next", item: album, position: .next)
        EnqueueButton("Play last", item: album, position: .last)
        Divider()
        FavoriteButton(albumId: album.id, isFavorite: album.isFavorite)
    }
}

struct NewAlbumContextMenu: ViewModifier {
    let album: AlbumDto

    func body(content: Content) -> some View {
        content
            .contextMenu { AlbumMenuOptions(album: album) }
    }
}

extension View {
    func albumContextMenu(for album: AlbumDto) -> some View {
        modifier(NewAlbumContextMenu(album: album))
    }
}
