import Defaults
import SwiftUI

struct SettingsScreen: View {
    var apiClient: ApiClient

    init(apiClient: ApiClient = .shared) {
        self.apiClient = apiClient
    }

    @State
    private var serverStatusValue = "unknown"

    @State
    private var serverStatusColor: Color = .gray

    @State
    private var checkInProgress = false

    var body: some View {
        NavigationStack {
            List {
                jellyfinSettings
                GeneralSettings()
                UserInterfaceSettings()
                miscSection
            }
            .navigationTitle("Settings")
            .listStyle(.insetGrouped)
            .buttonStyle(.plain)
            .navigationDestination(for: SettingsNav.self) { nav in
                switch nav {
                case .jellyfin:
                    JellyfinSettings(client: apiClient)
                }
            }
        }
    }

    @ViewBuilder
    private var jellyfinSettings: some View {
        NavigationLink(value: SettingsNav.jellyfin) {
            serverStatus
        }
    }

    @ViewBuilder
    private var serverStatus: some View {
        HStack {
            Text("Jellyfin server")
            Spacer()

            if checkInProgress {
                ProgressView()
                    .scaledToFit()
            } else {
                Text(serverStatusValue)
                    .foregroundStyle(serverStatusColor)
            }
        }
        .task {
            checkInProgress = true
            defer { checkInProgress = false }
            let status = await apiClient.getServerStatus()
            serverStatusValue = status.rawValue
            switch status {
            case .offline:
                serverStatusColor = .red
            case .online:
                serverStatusColor = .green
            default:
                serverStatusColor = .gray
            }
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
        .onChange(of: previewEnabled) {
            if previewEnabled {
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
