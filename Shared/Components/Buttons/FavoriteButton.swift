import SwiftUI

struct FavoriteButton: View {
    @State
    var isFavorite = false

    let albumRepo: AlbumRepository
    let songRepo: SongRepository
    let item: any JellyfinItem
    let textTrue: String?
    let textFalse: String?

    init(
        item: any JellyfinItem,
        textTrue: String? = nil,
        textFalse: String? = nil,
        albumRepo: AlbumRepository = .shared,
        songRepo: SongRepository = .shared
    ) {
        self.item = item
        self.textTrue = textTrue
        self.textFalse = textFalse
        self.albumRepo = albumRepo
        self.songRepo = songRepo
    }

    var body: some View {
        Button {
            action()
        } label: {
            FavoriteIcon(isFavorite: isFavorite)
            buttonText(isFavorite ? textTrue : textFalse)
        }
    }

    @ViewBuilder
    func buttonText(_ text: String?) -> some View {
        if let text {
            Text(text)
        }
    }

    func action() {
        Task {
            do {
                switch item {
                case let album as Album:
                    try await albumRepo.setFavorite(albumId: album.uuid, isFavorite: isFavorite)
                case let song as Song:
                    try await songRepo.setFavorite(songId: song.uuid, isFavorite: isFavorite)
                default:
                    print("Unhandled type")
                }

                await MainActor.run { isFavorite.toggle() }
            } catch {
                print("Failed to update favorite status")
            }
        }
    }
}

#if DEBUG
struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButton(
            item: PreviewData.albums.first!,
            albumRepo: .init(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)),
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
    }
}
#endif
