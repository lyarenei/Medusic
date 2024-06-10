import Foundation

extension LibraryRepository {
    /// Get artist by ID.
    func getArtist(by id: String) async throws -> ArtistDto {
        guard let artist = await artists.by(id: id) else { throw LibraryRepositoryError.notFound }
        return artist
    }

    /// Set favorite flag for artist both locally and in Jellyfin.
    @available(*, deprecated, message: "Use method which accepts ID")
    func setFavorite(artist: ArtistDto, isFavorite: Bool) async throws {
        guard var newArtist = await artists.by(id: artist.id) else { throw LibraryRepositoryError.notFound }
        try await apiClient.services.mediaService.setFavorite(itemId: artist.id, isFavorite: isFavorite)
        newArtist.isFavorite = isFavorite
        try await $artists.insert(newArtist)
    }

    /// Set favorite flag for artist both locally and in Jellyfin.
    func setFavorite(artistId: String, isFavorite: Bool) async throws {
        do {
            guard var artist = await artists.by(id: artistId) else { throw LibraryRepositoryError.notFound }
            try await apiClient.services.mediaService.setFavorite(itemId: artistId, isFavorite: isFavorite)
            artist.isFavorite = isFavorite
            try await $artists.insert(artist)
        } catch let error as MedusicError {
            logger.logWarn(error)
            throw error
        } catch {
            logger.warning("Failed to update favorite status for artist \(artistId): \(error.localizedDescription)")
            throw error
        }
    }

    /// Get total runtime of all songs/albums for specified artist.
    nonisolated func getRuntime(for artist: ArtistDto) async -> TimeInterval {
        var totalRuntime: TimeInterval = 0
        for album in await getAlbums(for: artist) {
            totalRuntime += await getRuntime(for: album)
        }

        return totalRuntime
    }
}
