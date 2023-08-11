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

    }
}
