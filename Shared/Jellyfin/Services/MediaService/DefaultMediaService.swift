import Foundation
import JellyfinAPI

final class DefaultMediaService: MediaService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    func download(item id: String) async throws -> Data {
        throw MediaServiceError.invalid
    }

    func stream(item id: String, bitrate: Int32?) async throws -> Data {
        throw MediaServiceError.invalid
    }
}
