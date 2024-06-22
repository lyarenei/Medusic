import SwiftUI

struct SongMenuOptions: View {
    let song: SongDto

    var body: some View {
        DownloadSongButton(songId: song.id, isDownloaded: song.isDownloaded)
        Divider()
        PlayButton("Play", item: song)
        EnqueueButton("Play next", item: song, position: .next)
        EnqueueButton("Play last", item: song, position: .last)
        Divider()
        FavoriteButton(songId: song.id, isFavorite: song.isFavorite)
    }
}

struct SongContextMenu: ViewModifier {
    let song: SongDto

    func body(content: Content) -> some View {
        content
            .contextMenu { SongMenuOptions(song: song) }
    }
}

extension View {
    func songContextMenu(for song: SongDto) -> some View {
        modifier(SongContextMenu(song: song))
    }
}
