import Foundation

extension ArtistDetailScreen {
    @Observable
    final class ViewModel {
        private let repo: LibraryRepository
        private(set) var artist: Artist
        private(set) var albums: [Album]
        private(set) var runtime: TimeInterval

        init(artist: Artist, repo: LibraryRepository = .shared) {
            self.repo = repo
            self.artist = artist
            self.albums = []
            self.runtime = 0
        }

        func updateDetails() async {
            albums = await repo.getAlbums(for: artist)
            runtime = await repo.getRuntime(for: artist)
        }

        func onFavoriteButton() async {
            // TODO: update in repo and remote
            artist.isFavorite.toggle()
        }

        func onRefreshButton() async {
            // TODO: update artist, albums, etc...
            await updateDetails()
        }
    }
}
