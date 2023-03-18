import Foundation

protocol SystemService: ObservableObject {
    func getServerInfo() async throws -> JellyfinServerInfo
    func ping() async throws -> Bool

    // MARK: - User stuff (can be later moved to separate service if necessary)
    /// Logs in the user.
    /// If logged in successfully, a user ID is returned for use in other API calls.
    /// If empty, the user was not logged in.
    func logIn(username: String, password: String) async throws -> String
}

enum SystemServiceError: Error {
    case invalid
}
