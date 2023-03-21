import Boutique
import Foundation

final class MediaRepository: ObservableObject {
    @Stored
    private var downloaded: [DownloadedMedia]

    private let api: ApiClient

    init(store: Store<DownloadedMedia>) {
        self._downloaded = Stored(in: store)
        self.api = ApiClient()
    }

    /// Downloads the item from Jellyfin server and saves it into the store.
    func fetchItem(by itemId: String) async throws {
        let _ = try await self.api.performAuth()
        let downloadedMedia = try await self.api.services.mediaService.downloadItem(id: itemId)
        try await self.$downloaded.insert(downloadedMedia).run()
    }

    /// Get downloaded item from store.
    func getItem(by itemId: String) async -> DownloadedMedia? {
        return await self.$downloaded.items.first { $0.uuid == itemId }
    }
}
