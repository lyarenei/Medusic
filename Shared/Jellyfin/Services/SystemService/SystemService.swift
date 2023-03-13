import Foundation

protocol SystemService: ObservableObject {
    func getServerInfo() async throws -> JellyfinServerInfo
    func ping() async throws -> Bool

    // MARK: - User stuff (can be later moved to separate service if necessary)
    func logIn(username: String, password: String) async throws -> Bool
}

enum SystemServiceError: Error {
    case invalid
}
