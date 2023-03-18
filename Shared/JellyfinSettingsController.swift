import Defaults
import Foundation
import SwiftUI

final class JellyfinSettingsController: ObservableObject {
    @ObservedObject
    var serverStatusController = ServerStatusController()

    // TODO: figure out how to securely store this
    @State
    private var password = ""

    @Published
    var serverUrlEdit: String = ""

    @Published
    var usernameEdit: String = ""

    @Published
    var passwordEdit: String = ""

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
        return Defaults[.userId] != ""
    }

    func setServerStatus(urlChanged: Bool = false, credentialsChanged: Bool = false) async {
        if urlChanged { self.api.useDefaultMode() }
        if credentialsChanged { let _ = try? await self.api.performAuth() }
        return await self.serverStatusController.setStatus(
            isConfigured: self.isConfigured(),
            isOnline: try? await self.pingServer(),
            isLoggedIn: self.isLoggedIn()
        )
    }

    func validateUrl(_ url: String) -> Bool {
        if let url = URL(string: url) {
            return UIApplication.shared.canOpenURL(url)
        }

        return false
    }

    func saveUrl(_ newUrl: String) async {
        Defaults[.serverUrl] = newUrl
        await self.setServerStatus(urlChanged: true)
    }

    func restoreUrl() {
        self.serverUrlEdit = Defaults[.serverUrl]
    }

    func saveUsername(_ newUsername: String) async {
        Defaults[.username] = newUsername
        await self.setServerStatus(credentialsChanged: true)
    }

    func restoreUsername() {
        self.usernameEdit = Defaults[.username]
    }
}
