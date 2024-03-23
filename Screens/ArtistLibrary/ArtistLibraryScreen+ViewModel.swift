import Observation
import SwiftUI

extension ArtistLibraryScreen {
    @Observable
    final class ViewModel {
        private let repo: LibraryRepository
        private(set) var artists: [Artist]

        var filter: FilterOption = .all
        var sortBy: SortOption = .name
        var sortDirection: SortDirection = .ascending

        init(artists: [Artist], repo: LibraryRepository = .shared) {
            self.repo = repo
            self.artists = artists
            self.sortBy = .name
        }

        func onRefreshButton() async {
            do {
                try await repo.refreshArtists()
                artists = await repo.artists
            } catch {
                debugPrint("Refreshing artists failed", error)
                Alerts.error("Refresh failed")
            }
        }
    }
}
