import Foundation

protocol MediaService: ObservableObject {
    func downloadItem(id: String) async throws -> DownloadedMedia
    func stream(item id: String, bitrate: Int32?) async throws -> Data
}

enum MediaServiceError: Error {
    case invalid
    case itemNotFound
}
