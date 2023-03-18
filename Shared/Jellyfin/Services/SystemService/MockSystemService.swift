import Foundation

final class MockSystemService: SystemService {
    func getServerInfo() async throws -> JellyfinServerInfo {
        return JellyfinServerInfo(name: "ServerName", version: "10.x.y")
    }

    func ping() async throws -> Bool {
        return true
    }

    func logIn(username: String, password: String) async throws -> String {
        return "logged_in"
    }
}
