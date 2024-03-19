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
//            artist = await repo.artists.by(id: artist.id)
            albums = await repo.getAlbums(for: artist)
            runtime = await repo.getRuntime(for: artist)
        }

        func onFavoriteButton() async {
            do {
                try await repo.setFavorite(artist: artist, isFavorite: !artist.isFavorite)
                artist.isFavorite.toggle()
            } catch {
                debugPrint("Un/Favorite artist failed", error)
                Alerts.error("Action failed")
            }
        }

        func onRefreshButton() async {
            do {
                try await repo.refresh(artist: artist)
                try await repo.refreshAlbums(for: artist)
                await updateDetails()
            } catch {
                debugPrint("Refresh artist failed", error)
                Alerts.error("Action failed")
            }
        }

        func toggleAboutLineLimit() {
            aboutLineLimit = aboutLineLimit == 5 ? .max : 5
        }
    }
}
