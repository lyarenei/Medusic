import Foundation

final class MockSystemService: SystemService {
    func getServerInfo() async throws -> JellyfinServerInfo {
        return JellyfinServerInfo(name: "ServerName", version: "10.x.y")
    }
}
