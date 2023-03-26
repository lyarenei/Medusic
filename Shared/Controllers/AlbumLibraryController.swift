import Foundation
import OSLog

final class AlbumLibraryController: ObservableObject {
    @Published
    var albums: [Album]?

    private var albumRepo: AlbumRepository
    private var songRepo: SongRepository
    private let log: Logger = .library

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
            self.log.debug("Set albums for view. Current album count: \(self.albums?.count ?? .zero)")
        }
    }}

    func doRefresh() async {
        self.log.debug("Requested album refresh from album library")
        do {
            try await self.albumRepo.refresh()
            self.setAlbums()
        } catch {
            self.log.info("Album refresh failed: \(error.localizedDescription)")
        }
    }
}
