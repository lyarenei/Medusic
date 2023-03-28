import Foundation

protocol MediaService: ObservableObject {
    func downloadItem(id: String) async throws -> DownloadedMedia
    func stream(item id: String, bitrate: Int32?) async throws -> Data

    func new_downloadItem(id: String, destination: URL) async throws
}

enum MediaServiceError: Error {
    case invalid
    case itemNotFound
}
