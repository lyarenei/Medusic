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
        logger.debug("Refreshing data...")
        try await apiClient.performAuth()

        let context = getContext()
        try context.delete(model: Artist.self)

        var offset = 0
        while true {
            let artists = try await apiClient.services.artistService.getArtists(pageSize: pageSize, offset: offset)
            guard artists.isNotEmpty else {
                try context.save()
                return
            }

            for artist in artists {
                logger.debug("Processing artist \(artist.id) ...")
                let newArtist = Artist(
                    jellyfinId: artist.id,
                    name: artist.name,
                    sortName: artist.sortName,
                    aboutInfo: artist.about,
                    isFavorite: artist.isFavorite,
                    favoriteAt: .distantPast,
                    createdAt: artist.createdAt
                )

                context.insert(newArtist)

                logger.debug("Fetching albums for artist \(artist.id) ...")
                let albums = try await apiClient.services.albumService.getAlbums(for: artist, pageSize: nil, offset: nil)
                for album in albums {
                    logger.debug("Processing album \(album.id) ...")
                    let newAlbum = Album(
                        jellyfinId: album.id,
                        name: album.name,
                        sortName: album.sortName,
                        aboutInfo: .empty,
                        isFavorite: album.isFavorite,
                        favoriteAt: .distantPast,
                        createdAt: album.createdAt
                    )

                    context.insert(newAlbum)
                    newArtist.albums.append(newAlbum)
                }
            }

            offset += pageSize
        }
    }
}
