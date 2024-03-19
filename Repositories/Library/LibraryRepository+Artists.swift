import Foundation

extension LibraryRepository {
    /// Get artist by ID.
    func getArtist(by id: String) async throws -> Artist {
        guard let artist = await artists.by(id: id) else { throw LibraryError.notFound }
        return artist
    }

    /// Set favorite flag for artist both locally and in Jellyfin.
    func setFavorite(artist: Artist, isFavorite: Bool) async throws {
        guard var newArtist = await artists.by(id: artist.id) else { throw LibraryError.notFound }
        try await apiClient.services.mediaService.setFavorite(itemId: artist.id, isFavorite: isFavorite)
        newArtist.isFavorite = isFavorite
        try await $artists.insert(newArtist)
    }

    /// Get total runtime of all songs/albums for specified artist.
    nonisolated func getRuntime(for artist: Artist) async -> TimeInterval {
        var totalRuntime: TimeInterval = 0
        for album in await getAlbums(for: artist) {
            totalRuntime += await getRuntime(for: album)
        }

        return totalRuntime
    }
}
