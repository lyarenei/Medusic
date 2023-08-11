import Boutique
import Foundation

final class LibraryRepository: ObservableObject {
    private let apiClient: ApiClient

    @Stored
    var artists: [Artist]

    init(
        store: Store<Artist>,
        apiClient: ApiClient
    ) {
        self._artists = Stored(in: store)
        self.apiClient = apiClient
    }

    func refresh() async throws {
        try await apiClient.performAuth()
        try await $artists.removeAll()
        var pageSize: Int32 = 50
        var offset: Int32 = 0
        while true {
            let artists = try await apiClient.services.artistService.getArtists(pageSize: pageSize, offset: offset)
            guard artists.isNotEmpty else { return }
            try await $artists.insert(artists)
            offset += pageSize
        }
    }

    func refresh(artist: Artist) async throws {
        try await apiClient.performAuth()
    }
}
