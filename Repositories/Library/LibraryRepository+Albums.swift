import Foundation

extension LibraryRepository {
    /// Get artist by ID.
    func getAlbum(by id: String) async throws -> Album {
        guard let album = await albums.by(id: id) else { throw LibraryError.notFound }
        return album
    }

    /// Get albums for specified artist.
    nonisolated func getAlbums(for artist: Artist) async -> [Album] {
        await albums.filtered(by: .artistId(artist.id))
    }

    /// Get total runtime for specified album.
    nonisolated func getRuntime(for album: Album) async -> TimeInterval {
        var totalRuntime: TimeInterval = 0
        for song in await getSongs(for: album) {
            totalRuntime += song.runtime
        }

        return totalRuntime
    }

    /// Refresh all albums for a specified artists. The songs in these albums are refreshed as well.
    /// Removes albums no longer associated with the artist.
    func refreshAlbums(for artist: Artist) async throws {
        guard let artist = await artists.by(id: artist.id) else { throw LibraryError.notFound }
        let oldAlbums = await albums.filtered(by: .artistId(artist.id))
        let newAlbums = try await apiClient.services.albumService.getAlbums(for: artist, pageSize: nil, offset: nil)
        let toRemove = Array(Set(oldAlbums).subtracting(newAlbums))
        try await $albums.remove(toRemove).insert(newAlbums).run()
        for album in newAlbums {
            try await refreshSongs(for: album)
        }
    }
}
