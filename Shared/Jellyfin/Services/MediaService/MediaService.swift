import Foundation

protocol MediaService: ObservableObject {
    func stream(item id: String, bitrate: Int32?) async throws -> Data

    func new_downloadItem(id: String, destination: URL) async throws
}

enum MediaServiceError: Error {
    case invalid
    case itemNotFound
}
