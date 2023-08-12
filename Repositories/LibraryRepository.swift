import Boutique
import Foundation
import OSLog

final class LibraryRepository: ObservableObject {
    private let apiClient: ApiClient

    @Stored
    var artists: [Artist]

    @Stored
    var albums: [Album]

    @Stored
    var songs: [Song]

    init(
        artistStore: Store<Artist>,
        albumStore: Store<Album>,
        songStore: Store<Song>,
        apiClient: ApiClient
    ) {
        self._artists = Stored(in: artistStore)
        self._albums = Stored(in: albumStore)
        self._songs = Stored(in: songStore)
        self.apiClient = apiClient
    }

    enum LibraryError: Error {
        case notFound
    }

    func refreshAll() async throws {
        try await refreshArtists()
        try await refreshAlbums()
        try await refreshSongs()
    }

    func removeAll() async throws {
        try await $artists.removeAll()
        try await $albums.removeAll()
        try await $songs.removeAll()
    }

    // MARK: - Artists

    func refreshArtists() async throws {
        Logger.library.debug("Refreshing artists...")
        try await apiClient.performAuth()

        try await $artists.removeAll()
        let pageSize: Int32 = 50
        var offset: Int32 = 0
        while true {
            let artists = try await apiClient.services.artistService.getArtists(pageSize: pageSize, offset: offset)
            guard artists.isNotEmpty else { return }
            try await $artists.insert(artists)
            offset += pageSize
        }
    }

    func refresh(artist: Artist) async throws {
        Logger.library.debug("Refreshing artist \(artist.id)...")
        // TODO: implementation
        try await apiClient.performAuth()
    }

    func setFavorite(artist: Artist, isFavorite: Bool) async throws {
        // TODO: implementation
    }

    @MainActor
    func getArtistName(for album: Album) -> String {
        artists.by(id: album.artistId)?.name ?? .empty
    }

    // MARK: - Albums

    func refreshAlbums() async throws {
        Logger.library.debug("Refreshing albums...")
        try await apiClient.performAuth()

        try await $albums.removeAll()
        let pageSize: Int32 = 50
        var offset: Int32 = 0
        while true {
            let albums = try await apiClient.services.albumService.getAlbums(pageSize: pageSize, offset: offset)
            guard albums.isNotEmpty else { return }
            try await $albums.insert(albums)
            offset += pageSize
        }
    }

    func refresh(albumId: String) async throws {
        Logger.library.debug("Refreshing album \(albumId)...")
        try await apiClient.performAuth()
        let remoteAlbum = try await apiClient.services.albumService.getAlbumById(albumId)
        try await $albums.insert(remoteAlbum)
    }

    func refresh(album: Album) async throws {
        try await refresh(albumId: album.id)
    }

    func setFavorite(album: Album, isFavorite: Bool) async throws {
        guard var album = await $albums.items.by(id: album.id) else { throw LibraryError.notFound }
        try await apiClient.services.mediaService.setFavorite(itemId: album.id, isFavorite: isFavorite)
        album.isFavorite = isFavorite
        try await $albums.insert(album)
    }

    // MARK: - Songs

    func refreshSongs() async throws {
        Logger.library.debug("Refreshing songs...")
        try await apiClient.performAuth()

        try await $songs.removeAll()
        let pageSize: Int32 = 250
        var offset: Int32 = 0
        while true {
            let songs = try await apiClient.services.songService.getSongs()
            guard songs.isNotEmpty else { return }
            try await $songs.insert(songs)
            offset += pageSize
        }
    }

    /// Refresh songs for specified album ID.
    func refreshSongs(for albumId: String) async throws {
        Logger.library.debug("Refreshing songs for album \(albumId)...")
        try await apiClient.performAuth()

        let localSongs = await $songs.items.filterByAlbum(id: albumId)
        let remoteSongs = try await apiClient.services.songService.getSongs(for: albumId)
        try await $songs.remove(localSongs).insert(remoteSongs).run()
    }

    func setFavorite(song: Song, isFavorite: Bool) async throws {
        guard var song = await $songs.items.by(id: song.id) else { throw LibraryError.notFound }
        try await apiClient.services.mediaService.setFavorite(itemId: song.id, isFavorite: isFavorite)
        song.isFavorite = isFavorite
        try await $songs.insert(song)
    }
}
