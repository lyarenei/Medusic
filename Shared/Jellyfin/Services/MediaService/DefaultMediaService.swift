import Foundation
import JellyfinAPI

final class DefaultMediaService: MediaService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    func downloadItem(id: String) async throws -> DownloadedMedia {
        let request = JellyfinAPI.Paths.getDownload(itemID: id)
        let response = try await client.send(request)
        return DownloadedMedia(uuid: id, data: response.value)
    }

    func stream(item id: String, bitrate: Int32?) async throws -> Data {
        throw MediaServiceError.invalid
    }
}
