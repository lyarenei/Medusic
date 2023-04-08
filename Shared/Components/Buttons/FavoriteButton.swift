import SwiftUI

struct FavoriteButton: View {
    @State
    var isFavorite: Bool = false

    private let albumRepo: AlbumRepository
    private let songRepo: SongRepository
    let item: Item

    init(
        item: Item,
        isFavorite: Bool,
        albumRepo: AlbumRepository = .shared,
        songRepo: SongRepository = .shared
    ) {
        self.item = item
        self.isFavorite = isFavorite
        self.albumRepo = albumRepo
        self.songRepo = songRepo
    }

    var body: some View {
        Button {
            action()
        } label: {
            FavoriteIcon(isFavorite: isFavorite)
        }
    }

    func action() {
        Task(priority: .userInitiated) {
            do {
                switch item {
                case .album(let id):
                    try await albumRepo.setFavorite(albumId: id, isFavorite: isFavorite)
                case .song(let id):
                    try await songRepo.setFavorite(songId: id, isFavorite: isFavorite)
                }

                await MainActor.run { isFavorite.toggle() }
            } catch {
                print("Failed to update favorite status")
            }
        }
    }

    enum Item {
        case album(id: String)
        case song(id: String)
    }
}

#if DEBUG
struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButton(
            item: .album(id: PreviewData.albums.first!.uuid),
            isFavorite: false,
            albumRepo: .init(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)),
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
    }
}
#endif
