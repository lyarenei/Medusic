import Foundation
import SwiftUI

final class LibraryController: ObservableObject {
    @Published
    var favoriteAlbums: [Album]?

    private var albumRepo: AlbumRepository
    private var songRepo: SongRepository

    init(
        albumRepo: AlbumRepository = AlbumRepository.shared,
        songRepo: SongRepository = SongRepository.shared
    ) {
        self.albumRepo = albumRepo
        self.songRepo = songRepo
    }

    func setFavoriteAlbums() { DispatchQueue.main.async {
        self.favoriteAlbums = nil
        Task(priority: .background) {
            self.favoriteAlbums = await self.albumRepo.getFavorite()
        }
    }}
}
