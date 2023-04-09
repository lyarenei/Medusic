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
}
