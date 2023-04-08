import Foundation

final class SongLibraryController: ObservableObject {
    // TODO: handle null and empty states, like album library
    @Published
    var songs: [Song] = []

    var albumRepo: AlbumRepository
    var songRepo: SongRepository

    init(
        albumRepo: AlbumRepository = AlbumRepository.shared,
        songRepo: SongRepository = SongRepository.shared
    ) {
        self.albumRepo = albumRepo
        self.songRepo = songRepo
    }

    
}
