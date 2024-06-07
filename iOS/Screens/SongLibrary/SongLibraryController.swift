import Boutique
import Foundation
import OSLog

extension SongLibraryScreen {
    final class Controller: ObservableObject {
        @Stored
        var songs: [SongDto]

        private var apiClient: ApiClient
        private var logger: Logger

        init(
            songStore: Store<SongDto> = .songs,
            apiClient: ApiClient = .shared,
            logger: Logger = .library
        ) {
            self._songs = Stored(in: songStore)
            self.apiClient = apiClient
            self.logger = logger
        }

        func onFavoriteButton(songId: String, isFavorite: Bool) async {
            do {
                guard var song = await songs.by(id: songId) else { throw LibraryError.notFound }
                try await apiClient.services.mediaService.setFavorite(itemId: songId, isFavorite: isFavorite)
                song.isFavorite = isFavorite
                try await $songs.insert(song)
            } catch let error as LibraryError {
                logger.warning("Failed to update favorite status: \(error.localizedDescription)")
                Alerts.error("Action failed", reason: error.localizedDescription)
            } catch {
                logger.warning("Failed to update favorite status: \(error.localizedDescription)")
                Alerts.error("Action failed")
            }
        }
    }
}

final class SongDetailController: ObservableObject {
    @Stored
    private var albums: [AlbumDto]

    init(albumStore: Store<AlbumDto> = .albums) {
        self._albums = Stored(in: albumStore)
    }

    func getAlbumName(for albumId: String) async -> String? {
        await albums.by(id: albumId)?.name
    }
}
