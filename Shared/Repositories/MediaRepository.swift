import Boutique
import Foundation

final class MediaRepository: ObservableObject {
    static let shared = MediaRepository(store: .downloadedMedia)

    @Stored
    private var downloaded: [DownloadedMedia]

    private let api: ApiClient

    init(store: Store<DownloadedMedia>) {
        self._downloaded = Stored(in: store)
        self.api = ApiClient()
    }

    // TODO: this needs some sort of queuing if one wants to download multiple albums
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

    /// Remove item from store.
    func removeItem(id: String) async throws {
        if let item = await self.getItem(by: id) {
            return try await self.$downloaded.remove(item)
        }
    }
}
