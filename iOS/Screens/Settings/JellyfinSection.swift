import SwiftUI

// TODO: Implement validators (url is not garbage, user can log in)
extension SettingsScreen {
    struct JellyfinSection: View {
        @AppStorage(SettingsKeys.serverUrl)
        var serverUrl = ""

        @AppStorage(SettingsKeys.username)
        var username = ""

        // TODO: figure out how to securely store this
        @State
        var password = ""

        @State
        private var presentUrlEdit = false

        var body: some View {
            Section(
                header: Text("Jellyfin"),
                content: {
                    InputWithLabelComponent(
                        labelText: "URL",
                        labelSymbol: .link,
                        inputText: $serverUrl,
                        placeholderText: "Server URL"
                    )
                    .keyboardType(.URL)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)

                    InputWithLabelComponent(
                        labelText: "Username",
                        labelSymbol: .personCropCircle,
                        inputText: $username,
                        placeholderText: "Account username"
                    )
                    .disableAutocorrection(true)
                    .autocapitalization(.none)

                    InputWithLabelComponent(
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
        }
    }
}

#if DEBUG
struct JellyfinSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.api, .preview)
    }
}
#endif
