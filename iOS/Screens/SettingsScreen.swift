import Defaults
import SwiftUI

struct SettingsScreen: View {
    @Default(.streamBitrate)
    var streamBitrate: Int

    @Default(.downloadBitrate)
    var downloadBitrate: Int

    var apiClient: ApiClient

    init(apiClient: ApiClient = .shared) {
        self.apiClient = apiClient
    }

    var body: some View {
        NavigationView {
            List {
                jellyfinSection()
                generalSection()
            }
            .navigationTitle("Settings")
            .listStyle(.grouped)
            .buttonStyle(.plain)
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    func jellyfinSection() -> some View {
        Section {
            ServerUrlComponent()
            ServerCredentialsComponent()
        } header: {
            Text("Jellyfin")
        }

        Section {
            ServerStatusComponent(apiClient: apiClient)
        }
    }

    @ViewBuilder
    func generalSection() -> some View {
        Section {
            streamBitrateOption()
            downloadBitrateOption()
            appearance()
            advanced()

            #if DEBUG
            developer()
            #endif
        } header: {
            Text("General")
        }
    }

    @ViewBuilder
    private func streamBitrateOption() -> some View {
        Picker("Stream bitrate (kbps)", selection: $streamBitrate) {
            Text("Unlimited (default)").tag(-1)
            Text("320").tag(320_000)
            Text("256").tag(256_000)
            Text("192").tag(192_000)
            Text("128").tag(128_000)
            Text("64").tag(064_000)
        }
    }

    @ViewBuilder
    private func downloadBitrateOption() -> some View {
        Picker("Download bitrate (kbps)", selection: $downloadBitrate) {
            Text("Unlimited (default)").tag(-1)
            Text("320").tag(320_000)
            Text("256").tag(256_000)
            Text("192").tag(192_000)
            Text("128").tag(128_000)
            Text("64").tag(064_000)
        }
    }

    @ViewBuilder
    func appearance() -> some View {
        NavigationLink {
            AppearanceSettingsScreen()
        } label: {
            ListOptionComponent(
                symbol: .paintbrushPointed,
                text: "Appearance"
            )
        }
    }

    @ViewBuilder
    func advanced() -> some View {
        NavigationLink {
            AdvancedSettingsScreen()
        } label: {
            ListOptionComponent(
                symbol: .wrenchAndScrewdriver,
                text: "Advanced"
            )
        }
    }

    #if DEBUG
    @ViewBuilder
    func developer() -> some View {
        NavigationLink {
            DeveloperSettings(apiClient: apiClient)
        } label: {
            ListOptionComponent(
                symbol: .hammer,
                text: "Developer"
            )
        }
    }
    #endif
}

#if DEBUG
struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(apiClient: .init(previewEnabled: true))
    }
}
#endif

#if DEBUG
// MARK: - Developer settings

private struct DeveloperSettings: View {
    @Default(.previewMode)
    var previewEnabled: Bool

    @Default(.readOnly)
    var readOnlyEnabled: Bool

    var apiClient: ApiClient

    init(apiClient: ApiClient = .shared) {
        self.apiClient = apiClient
    }

    var body: some View {
        List {
            previewMode()
            readOnlyMode()
        }
        .listStyle(.grouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Developer")
    }

    @ViewBuilder
    private func previewMode() -> some View {
        Toggle(isOn: $previewEnabled) {
            ListOptionComponent(
                symbol: .eyes,
                text: "Preview mode"
            )
        }
        .onChange(of: previewEnabled) { isEnabled in
            if isEnabled {
                apiClient.usePreviewMode()
                return
            }

            apiClient.useDefaultMode()
        }
    }

    @ViewBuilder
    private func readOnlyMode() -> some View {
        Toggle(isOn: $readOnlyEnabled) {
            ListOptionComponent(
                symbol: .pencilSlash,
                text: "Read only mode"
            )
        }
    }
}
#endif
