import Foundation

final class MockSystemService: SystemService {
    func getServerInfo() async throws -> JellyfinServerInfo {
        JellyfinServerInfo(name: "ServerName", version: "10.x.y")
    }

    func ping() async throws -> Bool {
        true
    }

    func logIn(username: String, password: String) async throws -> String {
        "logged_in"
    }
}
