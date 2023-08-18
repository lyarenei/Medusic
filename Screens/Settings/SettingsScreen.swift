import Defaults
import SwiftUI

struct SettingsScreen: View {
    var apiClient: ApiClient

    init(apiClient: ApiClient = .shared) {
        self.apiClient = apiClient
    }

    var body: some View {
        NavigationView {
            List {
                jellyfinSection
                GeneralSettings()
                UserInterfaceSettings()
                miscSection
            }
            .navigationTitle("Settings")
            .listStyle(.grouped)
            .buttonStyle(.plain)
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private var jellyfinSection: some View {
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
    private var miscSection: some View {
        Section {
            advancedSettings

            #if DEBUG
            developerSettings
            #endif
        }
    }

    @ViewBuilder
    private var advancedSettings: some View {
        NavigationLink("Advanced") {
            AdvancedSettings()
                .environmentObject(FileRepository.shared)
        }
    }

    #if DEBUG
    @ViewBuilder
    private var developerSettings: some View {
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
