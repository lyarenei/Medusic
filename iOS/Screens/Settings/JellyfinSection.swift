import Defaults
import SwiftUI

// TODO: Implement validators (url is not garbage, user can log in)
extension SettingsScreen {
    struct JellyfinSection: View {
        @Default(.serverUrl)
        var serverUrl: String

        @Default(.username)
        var username: String

        // TODO: figure out how to securely store this
        @State
        var password = ""

        var body: some View {
            Section(
                header: Text("Jellyfin"),
                content: {
                    InlineInputComponent(
                        labelText: "URL",
                        labelSymbol: .link,
                        inputText: $serverUrl,
                        placeholderText: "Server URL"
                    )
                    .keyboardType(.URL)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)

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
        }
    }
}

#if DEBUG
struct JellyfinSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.api, .init())
    }
}
#endif
