import Foundation
import OSLog
import SwiftData

actor BackgroundDataManager {
    private var container: ModelContainer
    private var apiClient: ApiClient
    private var logger: Logger

    private let pageSize = 10

    init(with container: ModelContainer, using client: ApiClient = .shared, logger: Logger = .library) {
        self.container = container
        self.apiClient = client
        self.logger = logger
    }

    init() throws {
        try self.init(with: .init(for: Artist.self, Album.self, Song.self))
    }

    private func getContext() -> ModelContext {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        return context
    }

    /// Refresh whe whole library (artists, albums, songs).
    func refreshLibrary() async throws {
        logger.debug("Refreshing library...")
        try await apiClient.performAuth()

        let context = getContext()
        try context.delete(model: Artist.self)
        try context.delete(model: Album.self)
        try context.delete(model: Song.self)

        var offset = 0
        while true {
            let artists = try await apiClient.services.artistService.getArtists(pageSize: pageSize, offset: offset)
            guard artists.isNotEmpty else {
                try save(context)
                logger.info("Refreshing completed...")
                return
            }

            for artist in artists {
                logger.debug("Processing artist \(artist.id) ...")
                let newArtist = Artist(from: artist)
                context.insert(newArtist)

                logger.debug("Fetching albums for artist \(artist.id) ...")
                let albums = try await apiClient.services.albumService.getAlbums(for: artist, pageSize: nil, offset: nil)
                for album in albums {
                    logger.debug("Processing album \(album.id) ...")
                    let newAlbum = Album(from: album)
                    context.insert(newAlbum)

                    newArtist.albums.append(newAlbum)

                    logger.debug("Fetching songs for album \(album.id) ...")
                    let songs = try await apiClient.services.songService.getSongsForAlbum(id: album.id)
                    for song in songs {
                        logger.debug("Processing song \(song.id) ...")

                        let newSong = Song(from: song)
                        newAlbum.songs.append(newSong)
                    }
                }
            }

            try save(context)
            offset += pageSize
        }
    }

    func save(_ ctx: ModelContext) throws {
        do {
            try ctx.save()
        } catch {
            logger.warning("Failed to save data: \(error.localizedDescription)")
            throw DataManagerError.saveFailed
        }
    }

    func setFavoriteSong(id: PersistentIdentifier, isFavorite: Bool) async throws {
        do {
            let ctx = getContext()
            guard let song = ctx.model(for: id) as? Song else {
                throw DataManagerError.notFound
            }

            try await apiClient.services.mediaService.setFavorite(itemId: song.jellyfinId, isFavorite: isFavorite)
            song.isFavorite = isFavorite
            try save(ctx)
        } catch {
            logger.warning("Failed to update favorite status: \(error.localizedDescription)")
            throw error
        }
    }
}

enum DataManagerError: Error {
    case saveFailed
    case notFound

    var localizedDescription: String {
        switch self {
        case .saveFailed:
            return "Saving data failed."
        case .notFound:
            return "Item does not exist."
        }
    }
}

#if DEBUG
// swiftlint:disable all

@MainActor
struct PreviewDataSource {
    static var container: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Artist.self, Album.self, Song.self, configurations: config)

        for artist in PreviewData.artists {
            let newArtist = Artist(from: artist)
            container.mainContext.insert(newArtist)

            for album in PreviewData.albums where album.artistId == artist.id {
                let newAlbum = Album(from: album)
                container.mainContext.insert(newAlbum)

                newArtist.albums.append(newAlbum)

                for song in PreviewData.songs where song.albumId == album.id {
                    let newSong = Song(from: song)
                    container.mainContext.insert(newSong)
                    newAlbum.songs.append(newSong)
                }
            }
        }

        return container
    }
}

// swiftlint:enable all
#endif
