import SwiftUI

struct FavoriteButton: View {
    @State
    var isFavorite: Bool = false

    private let albumRepo: AlbumRepository
    private let songRepo: SongRepository
    let item: Item
    let textTrue: String?
    let textFalse: String?

    init(
        for item: Item,
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
            isFavorite ? buttonText(textTrue) : buttonText(textFalse)
        }
    }

    @ViewBuilder
    func buttonText(_ text: String?) -> some View {
        if let text = text {
            Text(text)
        }
    }

    func action() {
        Task(priority: .userInitiated) {
            do {
                switch item {
                case .album(let album):
                    try await albumRepo.setFavorite(albumId: album.uuid, isFavorite: isFavorite)
                case .song(let song):
                    try await songRepo.setFavorite(songId: song.uuid, isFavorite: isFavorite)
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
            for: .album(PreviewData.albums.first!),
            albumRepo: .init(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)),
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
    }
}
#endif
