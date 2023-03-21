import Foundation

protocol MediaService: ObservableObject {
    func download(item id: String) async throws -> Data
    func stream(item id: String, bitrate: Int32?) async throws -> Data
}

enum MediaServiceError: Error {
    case invalid
    case itemNotFound
}
