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
                    // TODO: smells like a component
                    Button {
                        presentUrlEdit.toggle()
                    } label: {
                        HStack {
                            Image(systemSymbol: .link)
                            Text("URL")
                            Spacer(minLength: 20)
                            Text(serverUrl)
                                .lineLimit(1)
                        }
                    }
                    .sheet(isPresented: $presentUrlEdit) {
                        // TODO: figure out how to present edit dialog
                        TextField(
                            "Server URL",
                            text: $serverUrl
                        )
                        .keyboardType(.URL)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    }

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
