import Foundation
import OSLog
import SwiftUI

final class LibraryController: ObservableObject {
    @Published
    var favoriteAlbums: [Album]?

    private let log: Logger = .library
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
        self.log.debug("Erased favorite albums")
        Task(priority: .background) {
            self.favoriteAlbums = await self.albumRepo.getFavorite()
            self.log.debug("Set favorite albums")
        }
    }}
}
