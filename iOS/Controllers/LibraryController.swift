import Foundation
import SwiftUI

final class LibraryController: ObservableObject {
    @Published
    var favoriteAlbums: [Album]?

    var albumRepo: AlbumRepository
    var songRepo: SongRepository

    init(
        albumRepo: AlbumRepository = AlbumRepository.shared,
        songRepo: SongRepository = SongRepository.shared
    ) {
        self.albumRepo = albumRepo
        self.songRepo = songRepo
    }

    func setFavoriteAlbums() { DispatchQueue.main.async {
        Task(priority: .background) {
            self.favoriteAlbums = await self.albumRepo.getFavorite()
        }
    }}
}
