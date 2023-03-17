import Defaults
import SFSafeSymbols
import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                List {
                    JellyfinSection()
                    GeneralSection()
                }
                .navigationTitle("Settings")
                .listStyle(.grouped)
                .buttonStyle(.plain)
            }
        }
    }
}

#if DEBUG
struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.api, .init())
    }
}
#endif

// MARK: - JellyfinSection view

// TODO: Implement validators (url is not garbage, user can log in)
// TODO: Implement controller and move all logic there
private struct JellyfinSection: View {
    @Default(.serverUrl)
    private var serverUrl: String

    @State
    private var serverUrlEdit: String = ""

    @Default(.username)
    private var username: String

    // TODO: figure out how to securely store this
    @State
    private var password = ""

    @State
    private var serverStatus: String = "unknown"

    @State
    private var statusColor: Color = Color(UIColor.separator)

    var body: some View {
        Section(
            header: Text("Jellyfin"),
            content: {
                InlineInputComponent(
                    labelText: "URL",
                    labelSymbol: .link,
                    inputText: $serverUrlEdit,
                    placeholderText: "Server URL"
                )
                .keyboardType(.URL)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onChange(of: serverUrlEdit) { newValue in
                    // TODO: delay to avoid spam
                    if self.validateUrl(newValue) {
                        serverUrl = newValue
                    } else {
                        // TODO: show in UI
                        print("Server URL is not valid")
                    }
                }
                .onAppear {
                    // TODO:
                    serverUrlEdit = serverUrl
                }

                InlineInputComponent(
                    labelText: "Username",
                    labelSymbol: .personCropCircle,
                    inputText: $username,
                    placeholderText: "Account username"
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)

                InlineInputComponent(
                    labelText: "Password",
                    labelSymbol: .key,
                    inputText: $password,
                    placeholderText: "Account password",
                    isSecure: true
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
            }
        )

        Section(content: {
            InlineValueComponent(
                labelText: "Server status",
                labelSymbol: .linkIcloud,
                value: $serverStatus
            )
            .foregroundColor(self.statusColor)
        })
    }

    func validateUrl(_ url: String) -> Bool {
        if let url = URL(string: url) {
            return UIApplication.shared.canOpenURL(url)
        }

        return false
    }

    func pingServer() {
        // TODO: if no config
        if true {
            self.serverStatus = "unknown"
            self.statusColor = .init(UIColor.separator)
            return
        }

        // TODO: if server ping
        if true {
            // TODO: consider showing online + logged in status
            self.serverStatus = "online"
            self.statusColor = .green
        } else {
            self.serverStatus = "offline"
            self.statusColor = .red
        }
    }
}
