import Foundation
import JellyfinAPI

final class DefaultSystemService: SystemService {

    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    func getServerInfo() async throws -> JellyfinServerInfo {
        let request = JellyfinAPI.Paths.getPublicSystemInfo
        let response = try await client.send(request)
        return JellyfinServerInfo(
            name: response.value.serverName ?? "unknown",
            version: response.value.version ?? "unknown")
    }

    func ping() async throws -> Bool {
        let request = JellyfinAPI.Paths.postPingSystem
        let response = try await client.send(request)

        if let statusCode = response.statusCode {
            return statusCode < 400
        }

        throw SystemServiceError.invalid
    }
}