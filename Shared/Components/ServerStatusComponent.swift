import DebouncedOnChange
import Defaults
import SwiftUI

struct ServerStatusComponent: View {
    @Default(.serverUrl)
    var serverUrl

    @Default(.username)
    var username

    @Environment(\.api)
    var api: ApiClient

    @State
    var serverStatus = "unknown"

    @State
    var statusColor: Color = .gray

    var body: some View {
        InlineValueComponent(
            labelText: "Server status",
            labelSymbol: .linkIcloud,
            value: $serverStatus
        )
        .foregroundColor(statusColor)
        .onChange(of: serverUrl, debounceTime: 1) { _ in
            Task { await refreshServerStatus() }
        }
        .onChange(of: username, debounceTime: 1) { _ in
            Task { await refreshServerStatus() }
        }
        // TODO: onChange of password
        .onAppear {
            Task { await refreshServerStatus() }
        }
    }

    func refreshServerStatus() async {
        var status = "unknown"
        var color: Color = .gray
        defer {
            serverStatus = status
            statusColor = color
        }

        guard isConfigured() else { return }
        api.useDefaultMode()

        // URL check
        status = "invalid URL"
        color = .red
        do {
            guard try await api.services.systemService.ping() else { return }
        } catch {
            print("Server ping failed: \(error.localizedDescription)")
            return
        }

        // Credentials check
        status = "invalid credentials"
        color = .yellow
        do {
            guard try await api.performAuth() else { return }
        } catch {
            print("Authentication failed: \(error.localizedDescription)")
            return
        }

        status = "online (logged in)"
        color = .green
    }

    func isConfigured() -> Bool {
        serverUrl.isNotEmpty && username.isNotEmpty
    }
}

#if DEBUG
struct ServerStatusComponent_Previews: PreviewProvider {
    static var previews: some View {
        ServerStatusComponent()
            .padding(.horizontal)
            .environment(\.api, ApiClient(previewEnabled: true))
    }
}
#endif
