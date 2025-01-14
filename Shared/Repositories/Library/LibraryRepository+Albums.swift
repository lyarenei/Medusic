import Foundation

extension LibraryRepository {
    /// Get album by ID.
    func getAlbum(by id: String) async throws -> AlbumDto {
        guard let album = await albums.by(id: id) else { throw LibraryRepositoryError.notFound }
        return album
    }

    /// Get albums for specified artist.
    nonisolated func getAlbums(for artist: ArtistDto) async -> [AlbumDto] {
        await albums.filtered(by: .artistId(artist.id))
    }

    /// Get total runtime for specified album.
    nonisolated func getRuntime(for album: AlbumDto) async -> TimeInterval {
        var totalRuntime: TimeInterval = 0
        for song in await getSongs(for: album) {
            totalRuntime += song.runtime
        }

        return totalRuntime
    }

    /// Set favorite flag for album both locally and in Jellyfin.
    func setFavorite(albumId: String, isFavorite: Bool) async throws {
        do {
            guard var album = await albums.by(id: albumId) else { throw LibraryRepositoryError.notFound }
            try await apiClient.services.mediaService.setFavorite(itemId: albumId, isFavorite: isFavorite)
            album.isFavorite = isFavorite
            try await $albums.insert(album)
        } catch let error as MedusicError {
            logger.logWarn(error)
            throw error
        } catch {
            logger.warning("Failed to update favorite status for album \(albumId): \(error.localizedDescription)")
            throw error
        }
    }

    /// Refresh all albums for a specified artists. The songs in these albums are refreshed as well.
    /// Removes albums no longer associated with the artist.
    func refreshAlbums(for artist: ArtistDto) async throws {
        guard let artist = await artists.by(id: artist.id) else { throw LibraryRepositoryError.notFound }
        let oldAlbums = await albums.filtered(by: .artistId(artist.id))
        let newAlbums = try await apiClient.services.albumService.getAlbums(for: artist, pageSize: nil, offset: nil)
        let toRemove = Array(Set(oldAlbums).subtracting(newAlbums))
        try await $albums.remove(toRemove).insert(newAlbums).run()
        for album in newAlbums {
            try await refreshSongs(for: album)
        }
    }
}
