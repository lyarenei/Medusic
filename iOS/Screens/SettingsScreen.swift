import Defaults
import SwiftUI

struct SettingsScreen: View {
    @Default(.streamBitrate)
    var streamBitrate: Int

    @Default(.downloadBitrate)
    var downloadBitrate: Int

    @Default(.primaryAction)
    var primaryAction: PrimaryAction

    var apiClient: ApiClient

    init(apiClient: ApiClient = .shared) {
        self.apiClient = apiClient
    }

    var body: some View {
        NavigationView {
            List {
                jellyfinSection()
                generalSection()
                miscSection()
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
            primaryActionOption()
        } header: {
            Text("General")
        }
    }

    @ViewBuilder
    private func miscSection() -> some View {
        Section {
            advanced()

            #if DEBUG
            developer()
            #endif
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
    private func primaryActionOption() -> some View {
        Picker("Primary action", selection: $primaryAction) {
            Text("Download (default)").tag(PrimaryAction.download)
            Text("Favorite").tag(PrimaryAction.favorite)
        }
    }

    @ViewBuilder
    private func advanced() -> some View {
        NavigationLink("Advanced") {
            AdvancedSettingsScreen()
        }
    }

    #if DEBUG
    @ViewBuilder
    private func developer() -> some View {
        NavigationLink("Developer") {
            DeveloperSettings(apiClient: apiClient)
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
            Text("Preview mode")
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
            Text("Read only mode")
        }
    }
}
#endif
