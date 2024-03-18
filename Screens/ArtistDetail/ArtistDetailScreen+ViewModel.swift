import Foundation
import Observation

extension ArtistDetailScreen {
    @Observable
    final class ViewModel {
        private let repo: LibraryRepository
        private(set) var artist: Artist
        private(set) var albums: [Album]
        private(set) var runtime: TimeInterval
        private(set) var aboutLineLimit: Int

        init(artist: Artist, repo: LibraryRepository = .shared) {
            self.repo = repo
            self.artist = artist
            self.albums = []
            self.runtime = 0
            self.aboutLineLimit = 5
        }

        func updateDetails() async {
            albums = await repo.getAlbums(for: artist)
            runtime = await repo.getRuntime(for: artist)
        }

        func onFavoriteButton() async {
            do {
                try await repo.setFavorite(artist: artist, isFavorite: !artist.isFavorite)
                artist.isFavorite.toggle()
            } catch {
                debugPrint("Un/Favorite action failed", error)
                Alerts.error("Action failed")
            }
        }

        func onRefreshButton() async {
            // TODO: update artist, albums, etc...
            await updateDetails()
        }

        func toggleAboutLineLimit() {
            aboutLineLimit = aboutLineLimit == 5 ? .max : 5
        }
    }
}
