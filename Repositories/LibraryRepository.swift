import Boutique
import Foundation
import OSLog

actor LibraryRepository: ObservableObject {
    enum LibraryError: Error {
        case notFound
    }

    static let shared = LibraryRepository(
        artistStore: .artists,
        albumStore: .albums,
        songStore: .songs,
        apiClient: .shared
    )

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

    /// Get number of albums for specified artist.
    nonisolated func getAlbumCount(for artist: Artist) async -> Int {
        await albums.filtered(by: .artistId(artist.id)).count
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

    /// Get total runtime of all songs/albums for specified artist.
    nonisolated func getRuntime(for artist: Artist) async -> TimeInterval {
        var totalRuntime: TimeInterval = 0
        for album in await getAlbums(for: artist) {
            totalRuntime += await getRuntime(for: album)
        }

        return totalRuntime
    }

    func setFavorite(artist: Artist, isFavorite: Bool) async throws {
        guard var newArtist = await artists.by(id: artist.id) else { throw LibraryError.notFound }
        try await apiClient.services.mediaService.setFavorite(itemId: artist.id, isFavorite: isFavorite)
        newArtist.isFavorite = isFavorite
        try await $artists.insert(newArtist)
    }

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

    // MARK: - Before actor

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
        let pageSize = 50
        var offset = 0
        while true {
            let artists = try await apiClient.services.artistService.getArtists(pageSize: pageSize, offset: offset)
            guard artists.isNotEmpty else { return }
            try await $artists.insert(artists)
            offset += pageSize
        }
    }

    func refresh(artist: Artist) async throws {
        try await refresh(artistId: artist.id)
    }

    func refresh(artistId: String) async throws {
        Logger.library.debug("Refreshing artist \(artistId)...")
        try await apiClient.performAuth()

        let artist = try await apiClient.services.artistService.getArtistById(artistId)
        try await $artists.insert(artist)
    }

    @available(*, deprecated, message: "Use .artistName property due to jellyfin bug")
    @MainActor
    func getArtistName(for album: Album) -> String {
        artists.by(id: album.artistId)?.name ?? .empty
    }

    // MARK: - Albums

    func refreshAlbums() async throws {
        Logger.library.debug("Refreshing albums...")
        try await apiClient.performAuth()

        try await $albums.removeAll()
        let pageSize = 50
        var offset = 0
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

    /// Get songs for a specified album. Songs are automatically sorted in the correct order.
    @MainActor
    func getSongs(for album: Album) -> [Song] {
        songs.filtered(by: .albumId(album.id)).sorted(by: .index).sorted(by: .albumDisc)
    }

    /// Get album disc count.
    @MainActor
    func getDiscCount(for album: Album) -> Int {
        let filteredSongs = songs.filter { $0.albumId == album.id }
        return filteredSongs.map(\.albumDisc).max() ?? 1
    }

    @MainActor
    func getRuntime(for album: Album) -> TimeInterval {
        var totalRuntime: TimeInterval = 0
        songs.filtered(by: .albumId(album.id)).forEach { totalRuntime += $0.runtime }
        return totalRuntime
    }

    // MARK: - Songs

    func refreshSongs() async throws {
        Logger.library.debug("Refreshing songs...")
        try await apiClient.performAuth()

        try await $songs.removeAll()
        let pageSize: Int32 = 250
        var offset: Int32 = 0
        while true {
            let songs = try await apiClient.services.songService.getSongs(pageSize: pageSize, offset: offset)
            guard songs.isNotEmpty else { return }
            try await $songs.insert(songs)
            offset += pageSize
        }
    }

    func refreshSongs(for album: Album) async throws {
        try await refreshSongs(for: album.id)
    }

    /// Refresh songs for specified album ID.
    func refreshSongs(for albumId: String) async throws {
        Logger.library.debug("Refreshing songs for album \(albumId)...")
        try await apiClient.performAuth()

        let localSongs = await $songs.items.filtered(by: .albumId(albumId))
        let remoteSongs = try await apiClient.services.songService.getSongsForAlbum(id: albumId)
        try await $songs.remove(localSongs).insert(remoteSongs).run()
    }

    func setFavorite(song: Song, isFavorite: Bool) async throws {
        guard var song = await $songs.items.by(id: song.id) else { throw LibraryError.notFound }
        try await apiClient.services.mediaService.setFavorite(itemId: song.id, isFavorite: isFavorite)
        song.isFavorite = isFavorite
        try await $songs.insert(song)
    }
}
