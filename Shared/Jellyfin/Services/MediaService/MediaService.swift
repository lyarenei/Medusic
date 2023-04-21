import Foundation

protocol MediaService: ObservableObject {
    func getStreamUrl(item id: String, bitrate: Int32?) -> URL?

    func new_downloadItem(id: String, destination: URL) async throws
}

enum MediaServiceError: Error {
    case invalid
    case itemNotFound
}
