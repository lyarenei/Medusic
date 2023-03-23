import Foundation

final class AlbumDetailController: ObservableObject {
    @Published
    var album: Album?

    @Published
    var songs: [Song]?

    @Published
    var isDownloaded: Bool = false

    @Published
    var isFavorite: Bool = false

    let albumId: String
    var albumRepo: AlbumRepository
    var songRepo: SongRepository

    init(
        albumId: String,
        albumRepo: AlbumRepository = AlbumRepository.shared,
        songRepo: SongRepository = SongRepository.shared
    ) {
        self.albumId = albumId
        self.albumRepo = albumRepo
        self.songRepo = songRepo
    }

    func setAlbum() { DispatchQueue.main.async {
        Task(priority: .background) {
            self.album = await self.albumRepo.getAlbum(by: self.albumId)
        }}
    }

    func setSongs() { DispatchQueue.main.async {
        Task(priority: .background) {
            self.songs = await self.songRepo.getSongs(ofAlbum: self.albumId)
        }}
    }

    func refresh() async {
        DispatchQueue.main.async { self.songs = nil }
        do {
            try await self.songRepo.refresh(for: self.albumId)
            self.setSongs()
        } catch {
            print("Failed to refresh the songs", error)
        }
    }
}
