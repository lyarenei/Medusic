import Defaults
import SwiftUI

extension SettingsScreen {
    // TODO: Implement validators (url is not garbage, user can log in)
    // TODO: Implement controller and move all logic there
    struct JellyfinSection: View {
        @Default(.serverUrl)
        var serverUrl: String

        @State
        var serverUrlEdit: String = ""

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
        }

        func validateUrl(_ url: String) -> Bool {
            if let url = URL(string: url) {
                return UIApplication.shared.canOpenURL(url)
            }

            return false
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
