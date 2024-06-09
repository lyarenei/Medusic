import Boutique
import Foundation
import OSLog

actor LibraryRepository: ObservableObject {
    static let shared = LibraryRepository()

    @Stored
    var artists: [ArtistDto]

    @Stored
    var albums: [AlbumDto]

    @Stored
    var songs: [SongDto]

    internal let apiClient: ApiClient
    internal let logger: Logger

    private var isConfigured: Bool
    private var cancellables: Cancellables

    init(
        artistStore: Store<ArtistDto> = .artists,
        albumStore: Store<AlbumDto> = .albums,
        songStore: Store<SongDto> = .songs,
        apiClient: ApiClient = .shared,
        logger: Logger = .library
    ) {
        self._artists = Stored(in: artistStore)
        self._albums = Stored(in: albumStore)
        self._songs = Stored(in: songStore)
        self.apiClient = apiClient
        self.logger = logger
        self.isConfigured = false
        self.cancellables = []

        Task { await configure() }
    }

    func configure() {
        guard !isConfigured else { return }

        NotificationCenter.default.publisher(for: .SongFileDownloaded)
            .sink { [weak self] event in
                guard let self,
                      let data = event.userInfo,
                      let songId = data["songId"] as? String
                else { return }

                Task {
                    if var song = await self.songs.by(id: songId) {
                        song.isDownloaded = true
                        do {
                            try await self.$songs.insert(song)
                        } catch {
                            self.logger.warning("Failed to mark song \(songId) as downloaded: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .SongFileDeleted)
            .sink { [weak self] event in
                guard let self,
                      let data = event.userInfo,
                      let songId = data["songId"] as? String
                else { return }

                Task {
                    if var song = await self.songs.by(id: songId) {
                        song.isDownloaded = false
                        do {
                            try await self.$songs.insert(song)
                        } catch {
                            self.logger.warning("Failed to unmark song \(songId) as downloaded: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .store(in: &cancellables)
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
        let pageSize = 50
        var offset = 0
        while true {
            let artists = try await apiClient.services.artistService.getArtists(pageSize: pageSize, offset: offset)
            guard artists.isNotEmpty else { return }
            try await $artists.insert(artists)
            offset += pageSize
        }
    }

    func refresh(artist: ArtistDto) async throws {
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
    func getArtistName(for album: AlbumDto) -> String {
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

    func refresh(album: AlbumDto) async throws {
        try await refresh(albumId: album.id)
    }

    /// Get songs for a specified album. Songs are automatically sorted in the correct order.
    @MainActor
    func getSongs(for album: AlbumDto) -> [SongDto] {
        songs.filtered(by: .albumId(album.id)).sorted(by: .index).sorted(by: .albumDisc)
    }

    /// Get album disc count.
    @MainActor
    func getDiscCount(for album: AlbumDto) -> Int {
        let filteredSongs = songs.filter { $0.albumId == album.id }
        return filteredSongs.map(\.albumDisc).max() ?? 1
    }

    @MainActor
    func getRuntime(for album: AlbumDto) -> TimeInterval {
        var totalRuntime: TimeInterval = 0
        songs.filtered(by: .albumId(album.id)).forEach { totalRuntime += $0.runtime }
        return totalRuntime
    }

    // MARK: - Songs

    func refreshSongs() async throws {
        Logger.library.debug("Refreshing songs...")
        try await apiClient.performAuth()

        try await $songs.removeAll()
        let pageSize = 250
        var offset = 0
        while true {
            let songs = try await apiClient.services.songService.getSongs(pageSize: pageSize, offset: offset)
            guard songs.isNotEmpty else { return }
            try await $songs.insert(songs)
            offset += pageSize
        }
    }

    func refreshSongs(for album: AlbumDto) async throws {
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
}
