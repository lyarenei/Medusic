import Foundation

protocol SystemService: ObservableObject {
    func getServerInfo() async throws -> JellyfinServerInfo
    func ping() async throws -> Bool
}

enum SystemServiceError: Error {
    case invalid
}
