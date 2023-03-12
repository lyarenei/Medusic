import SwiftUI
import SwiftUIBackports

extension SettingsScreen {
    struct AboutServer: View {
        @Environment(\.api)
        var api

        // TODO: == is server URL from config not empty
        @State
        private var isConfigured = true

        var body: some View {
            VStack(spacing: 0) {
                if isConfigured {
                    ServerInfo()
                        .font(.callout)
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                        .padding(.bottom, 15)
                } else {
                    Text("Jellyfin server not configured")
                        .font(.subheadline)
                }
            }
        }
    }
}

private struct InfoEntry: View {
    var name: String
    var value: String

    var body: some View {
        HStack(alignment: .center) {
            Text(name)
            Spacer()
            Text(value)
        }
    }
}

private struct ServerInfo: View {
    @Environment(\.api)
    var api

    @State
    private var isOnline = false

    @State
    private var serverName = ""

    @State
    private var serverVersion = ""

    var body: some View {
        let statusText = isOnline ? "online" : "offline"
        VStack(spacing: 5) {
            Text("Server information")
                .padding(.bottom, 15)

            InfoEntry(name: "Name", value: serverName)

            Divider()

            InfoEntry(name: "Version", value: serverVersion)

            Divider()

            if isOnline {
                InfoEntry(name: "Status", value: statusText)
                    .foregroundColor(.green)
            } else {
                InfoEntry(name: "Status", value: statusText)
                    .foregroundColor(.red)
            }

            Divider()
        }
        .backport.task {
            do {
                let serverInfo = try await api.systemService.getServerInfo()

                // Request succeeded, server must be online
                isOnline = true

                serverName = serverInfo.name
                serverVersion = serverInfo.version
            } catch {
                print("Failed to get server info: \(error)")
            }
        }
    }
}

#if DEBUG
struct AboutServer_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.api, .preview)
    }
}
#endif
