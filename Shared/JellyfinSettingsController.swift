import Defaults
import Foundation
import SwiftUI

final class JellyfinSettingsController: ObservableObject {
    @ObservedObject
    var serverStatusController = ServerStatusController()

    private let api: ApiClient

    init() {
        self.api = ApiClient()
    }

    private func isConfigured() -> Bool {
        return Defaults[.serverUrl] != "" && Defaults[.username] != ""
    }

    private func pingServer() async throws -> Bool {
        try await self.api.services.systemService.ping()
    }

    private func isLoggedIn() -> Bool {
        // TODO: Always true - it is persisted
        return Defaults[.userId] != ""
    }

    func setServerStatus(urlChanged: Bool = false) async {
        if urlChanged { api.useDefaultMode() }
        return await self.serverStatusController.setStatus(
            isConfigured: self.isConfigured(),
            isOnline: try? await self.pingServer(),
            isLoggedIn: self.isLoggedIn()
        )
    }
}
