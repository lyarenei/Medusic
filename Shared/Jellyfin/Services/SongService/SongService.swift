import Foundation

// TODO: Seems like userId should be stored somewhere at API, so it won't be necessary to pass it to every method
protocol SongService: ObservableObject {
    func getSongs(with userId: String) async throws -> [Song]
    func getSongs(with userId: String, for albumId: String) async throws -> [Song]
    func toggleFavorite(songId: String) async throws -> Bool
}
