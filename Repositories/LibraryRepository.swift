import Boutique
import Foundation

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

    func refreshArtists() async throws {
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

    func refreshAlbums() async throws {
        // TODO: pagination
        try await apiClient.performAuth()
        let remoteAlbums = try await apiClient.services.albumService.getAlbums()
        try await $albums.removeAll().insert(remoteAlbums).run()
    }

    func refreshSongs() async throws {
        // TODO: implementation
        try await apiClient.performAuth()
    }

    func refresh(artist: Artist) async throws {
        // TODO: implementation
        try await apiClient.performAuth()
    }

    func refresh(albumId: String) async throws {
        try await apiClient.performAuth()
        let remoteAlbum = try await apiClient.services.albumService.getAlbum(by: albumId)
        try await $albums.insert(remoteAlbum)
    }

    func refresh(album: Album) async throws {
        try await refresh(albumId: album.id)
    }

    func setFavorite(artist: Artist, isFavorite: Bool) async throws {
        // TODO: implementation
    }

    func setFavorite(album: Album, isFavorite: Bool) async throws {
        guard var album = await $albums.items.by(id: album.id) else { throw LibraryError.notFound }
        try await apiClient.services.mediaService.setFavorite(itemId: album.id, isFavorite: isFavorite)
        album.isFavorite = isFavorite
        try await $albums.insert(album)
    }

    func setFavorite(song: Song, isFavorite: Bool) async throws {
        guard var song = await $songs.items.by(id: song.id) else { throw LibraryError.notFound }
        try await apiClient.services.mediaService.setFavorite(itemId: song.id, isFavorite: isFavorite)
        song.isFavorite = isFavorite
        try await $songs.insert(song)
    }

    @MainActor
    func getArtistName(for album: Album) -> String {
        artists.by(id: album.artistId)?.name ?? .empty
    }
}
