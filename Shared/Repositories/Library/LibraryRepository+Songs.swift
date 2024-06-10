import Foundation

extension LibraryRepository {
    /// Get songs for a specified album. Songs are automatically sorted in the correct order.
    nonisolated func getSongs(for album: AlbumDto) async -> [SongDto] {
        await songs.filtered(by: .albumId(album.id)).sorted(by: .index).sorted(by: .albumDisc)
    }

    /// Set favorite flag for song both locally and in Jellyfin.
    func setFavorite(songId: String, isFavorite: Bool) async throws {
        do {
            guard var song = await songs.by(id: songId) else { throw LibraryRepositoryError.notFound }
            try await apiClient.services.mediaService.setFavorite(itemId: songId, isFavorite: isFavorite)
            song.isFavorite = isFavorite
            try await $songs.insert(song)
        } catch let error as MedusicError {
            logger.logWarn(error)
            throw error
        } catch {
            logger.warning("Failed to update favorite status for song \(songId): \(error.localizedDescription)")
            throw error
        }
    }
}
