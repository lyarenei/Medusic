import SwiftUI

extension SettingsScreen {
    struct JellyfinSection: View {
        var body: some View {
            Section(
                header: Text("Jellyfin"),
                content: {
                    Button {
                        // Spawn sheet with server url form
                    } label: {
                        Image(systemSymbol: .link)
                        Text("Server URL")
                    }

                    Button {
                        // Spawn sheet with account form
                    } label: {
                        Image(systemSymbol: .personCropCircle)
                        Text("Account")
                    }
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
