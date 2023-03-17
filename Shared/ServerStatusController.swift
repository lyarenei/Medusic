import Foundation
import SwiftUI

final class ServerStatusController: ObservableObject {
    @Published
    var serverStatus: String = "unknown"

    @Published
    var statusColor: Color = .init(UIColor.separator)

    func setStatus(isConfigured: Bool, isOnline: Bool?, isLoggedIn: Bool) async {
        guard isConfigured else { return setUnknown() }
        guard let online = isOnline else { return setUnknown() }
        return online ? setOnline(isLoggedIn: isLoggedIn) : setOffline()
    }

    private func setUnknown() {
        DispatchQueue.main.async {
            self.serverStatus = "unknown"
            self.statusColor = .init(UIColor.separator)
        }
    }

    private func setOnline(isLoggedIn: Bool) {
        let text = isLoggedIn ? "online (logged in)" : "(online)"
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
