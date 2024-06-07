import Foundation

extension LibraryRepository {
    /// Get songs for a specified album. Songs are automatically sorted in the correct order.
    nonisolated func getSongs(for album: AlbumDto) async -> [SongDto] {
        await songs.filtered(by: .albumId(album.id)).sorted(by: .index).sorted(by: .albumDisc)
    }

    func setFavorite(songId: String, isFavorite: Bool) async {
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
