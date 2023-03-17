import Defaults
import Foundation
import SwiftUI

final class ServerStatusController: ObservableObject {
    @Published
    var serverStatus: String = "unknown"

    @Published
    var statusColor: Color = Color(UIColor.separator)

    private let api: ApiClient

    init() {
        self.api = ApiClient()
    }

    private func isConfigured() -> Bool {
        return Defaults[.serverUrl] != "" && Defaults[.username] != ""
    }

    private func pingServer() async throws -> Bool {
        try await api.services.systemService.ping()
    }

    private func isLoggedIn() -> Bool {
        // TODO: Always true - it is persisted
        return Defaults[.userId] != ""
    }

    func setStatus() async {
        guard self.isConfigured() else { return self.setUnknown() }
        do {
            return try await self.pingServer() ? setOnline() : setOffline()
        } catch {
            print("Failed to get server status", error)
            self.setUnknown()
        }
    }

    private func setUnknown() {
        DispatchQueue.main.async {
            self.serverStatus = "unknown"
            self.statusColor = .init(UIColor.separator)
        }
    }

    private func setOnline() {
        let text = self.isLoggedIn() ? "online (logged in)" : "(online)"
        DispatchQueue.main.async {
            self.serverStatus = text
            self.statusColor = .green
        }
    }

    private func setOffline() {
        DispatchQueue.main.async {
            self.serverStatus = "offline"
            self.statusColor = .red
        }
    }
}
