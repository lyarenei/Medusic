import Foundation
import OSLog
import SwiftData

actor BackgroundDataManager {
    private var container: ModelContainer
    private var apiClient: ApiClient
    private var logger: Logger

    private let pageSize = 50

    init(with container: ModelContainer, using client: ApiClient = .shared, logger: Logger = .library) {
        self.container = container
        self.apiClient = client
        self.logger = logger
    }

    private func getContext() -> ModelContext {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        return context
    }

    /// Refresh whe whole library (artists, albums, songs).
    func refresh() async throws {
        // TODO: This should probably be for a specific artist, not for whole library. But we will see.
        logger.debug("Refreshing data...")
        try await apiClient.performAuth()

        let context = getContext()
        try context.delete(model: Artist.self)
        try context.delete(model: Album.self)
        try context.delete(model: Song.self)

        var offset = 0
        while true {
            let artists = try await apiClient.services.artistService.getArtists(pageSize: pageSize, offset: offset)
            guard artists.isNotEmpty else {
                try context.save()
                logger.debug("Refreshing completed...")
                return
            }

            for artist in artists {
                logger.debug("Processing artist \(artist.id) ...")
                let newArtist = Artist(from: artist)

                logger.debug("Fetching albums for artist \(artist.id) ...")
                let albums = try await apiClient.services.albumService.getAlbums(for: artist, pageSize: nil, offset: nil)
                for album in albums {
                    logger.debug("Processing album \(album.id) ...")

                    let newAlbum = Album(
                        jellyfinId: album.id,
                        name: album.name,
                        albumArtist: newArtist,
                        sortName: album.sortName,
                        aboutInfo: .empty,
                        isFavorite: album.isFavorite,
                        favoriteAt: .distantPast,
                        createdAt: album.createdAt
                    )

                    logger.debug("Fetching songs for album \(album.id) ...")
                    let songs = try await apiClient.services.songService.getSongsForAlbum(id: album.id)
                    for song in songs {
                        logger.debug("Processing song \(song.id) ...")

                        var songArtists: [Artist] = []
                        if let existingSong = try context.fetch(Song.fetchBy(song.id)).first {
                            songArtists = existingSong.artists
                        }

                        if !songArtists.contains(newArtist) {
                            songArtists.append(newArtist)
                        }

                        let newSong = Song(
                            jellyfinId: song.id,
                            name: song.name,
                            album: newAlbum,
                            albumIndex: song.index,
                            sortName: song.sortName,
                            isFavorite: song.isFavorite,
                            favoriteAt: .distantPast,
                            createdAt: song.createdAt,
                            albumDisc: song.albumDisc,
                            artists: songArtists,
                            runtime: song.runtime,
                            fileSize: song.size,
                            fileExtension: song.fileExtension
                        )
                    }
                }

                context.insert(newArtist)
            }

            try context.save()
            offset += pageSize
        }
    }
}

#if DEBUG
// swiftlint:disable all

@MainActor
struct PreviewDataSource {
    static var container: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Artist.self, configurations: config)

        for artist in PreviewData.artists {
            let newArtist = Artist(from: artist)

            // TODO: albums for artist

            container.mainContext.insert(newArtist)
        }

        return container
    }
}

// swiftlint:enable all
#endif
