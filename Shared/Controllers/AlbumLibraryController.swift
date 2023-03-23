import Foundation

final class AlbumLibraryController: ObservableObject {
    @Published
    var albums: [Album]?

    var albumRepo: AlbumRepository
    var songRepo: SongRepository

    init(
        albumRepo: AlbumRepository = AlbumRepository.shared,
        songRepo: SongRepository = SongRepository.shared
    ) {
        self.albumRepo = albumRepo
        self.songRepo = songRepo
    }

    func setAlbums() { DispatchQueue.main.async {
        Task(priority: .background) {
            self.albums = await self.albumRepo.getAlbums()
        }
    }}

    func doRefresh() async {
        do {
            try await self.albumRepo.refresh()
            self.setAlbums()
        } catch {
            print("Refreshing albums failed", error)
        }
    }
}
