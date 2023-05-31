import Foundation

protocol SongService: ObservableObject {
    func getSongs() async throws -> [Song]
    func getSongs(for albumId: String) async throws -> [Song]
}

enum SongServiceError: Error {
    case noData
}
