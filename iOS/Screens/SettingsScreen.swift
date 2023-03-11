import SFSafeSymbols
import SwiftUI

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
    private var serverUrl = ""

    @State
    private var serverVersion = ""

    var body: some View {
        let statusText = isOnline ? "online" : "offline"
        VStack(spacing: 5) {
            Text("Server information")
                .padding(.bottom, 15)

            InfoEntry(name: "URL", value: serverUrl)
            InfoEntry(name: "Name", value: serverName)
            InfoEntry(name: "Version", value: serverVersion)

            if isOnline {
                InfoEntry(name: "Status", value: statusText)
                    .foregroundColor(.green)
            } else {
                InfoEntry(name: "Status", value: statusText)
                    .foregroundColor(.red)
            }
        }
    }
}

private struct AboutSever: View {
    @Environment(\.api)
    var api

    @State
    private var isConnected = false

    var body: some View {
        if isConnected {
            ServerInfo()
                .font(.callout)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .padding(.bottom, 15)
        } else {
            Text("Not connected to Jellyfin server")
                .font(.subheadline)
        }
    }
}

struct SettingsScreen: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                List {
                    NavigationLink {
                        AccountSettingsView()
                    } label: {
                        Image(systemSymbol: .personCropCircle)
                        Text("Account")
                    }

                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        Image(systemSymbol: .paintbrushPointed)
                        Text("Appearance")
                    }
                }
                .navigationTitle("Settings")
                .listStyle(.grouped)

                AboutSever()
            }
        }
    }
}

#if DEBUG
struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.api, .preview)
    }
}
#endif
