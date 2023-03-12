import SwiftUI

// TODO: Implement validators (url is not garbage, user can log in)
extension SettingsScreen {
    struct JellyfinSection: View {
        // TODO: would be nice to actually save these somewhere

        @State
        var serverUrl = ""

        @State
        var username = ""

        @State
        var password = ""

        var body: some View {
            Section(
                header: Text("Jellyfin"),
                content: {
                    TextField(
                        "Server URL",
                        text: $serverUrl
                    )
                    .keyboardType(.URL)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)

                    TextField(
                        "Username",
                        text: $username
                    )
                    .disableAutocorrection(true)
                    .autocapitalization(.none)

                    SecureField(
                        "Password",
                        text: $password
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
