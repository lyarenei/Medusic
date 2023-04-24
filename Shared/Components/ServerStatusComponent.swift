import DebouncedOnChange
import Defaults
import SwiftUI

struct ServerStatusComponent: View {
    @Default(.serverUrl)
    var serverUrl

    @Default(.username)
    var username

    @State
    var serverStatus = "unknown"

    @State
    var statusColor: Color = .gray

    let apiClient: ApiClient

    init(apiClient: ApiClient = .shared) {
        self.apiClient = apiClient
    }

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

        // URL check
        status = "invalid URL"
        color = .red
        do {
            guard try await apiClient.services.systemService.ping() else { return }
        } catch {
            print("Server ping failed: \(error.localizedDescription)")
            return
        }

        // Credentials check
        status = "invalid credentials"
        color = .yellow
        do {
            try await apiClient.performAuth()
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
        ServerStatusComponent(apiClient: .init(previewEnabled: true))
            .padding(.horizontal)
    }
}
#endif
