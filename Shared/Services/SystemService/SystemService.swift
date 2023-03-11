import Foundation

protocol SystemService: ObservableObject {
    func getServerInfo() async throws -> JellyfinServerInfo
}
