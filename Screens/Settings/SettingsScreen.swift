import Defaults
import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject
    private var apiClient: ApiClient

    @State
    private var serverStatusValue = "unknown"

    @State
    private var serverStatusColor: Color = .gray

    @State
    private var checkInProgress = false

    @State
    private var navPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navPath) {
            List {
                jellyfinSettings
                GeneralSettings()

                miscSection
            }
            .navigationTitle("Settings")
            .listStyle(.insetGrouped)
            .buttonStyle(.plain)
            .navigationDestination(for: SettingsNav.self) { nav in
                switch nav {
                case .advanced:
                    AdvancedSettings()
                        .environmentObject(FileRepository.shared)
                case .appearance:
                    AppearanceSettings()
                case .jellyfin:
                    JellyfinSettings(client: apiClient)

                #if DEBUG
                case .developer:
                    DeveloperSettings(apiClient: apiClient)
                #endif
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
            appearanceSettings
            advancedSettings

            #if DEBUG
            developerSettings
            #endif
        }
    }

    @ViewBuilder
    private var advancedSettings: some View {
        NavigationLink(value: SettingsNav.advanced) {
            Text("Advanced")
        }
    }

    @ViewBuilder
    private var appearanceSettings: some View {
        NavigationLink(value: SettingsNav.appearance) {
            Text("Appearance")
        }
    }

    #if DEBUG
    @ViewBuilder
    private var developerSettings: some View {
        NavigationLink(value: SettingsNav.developer) {
            Text("Developer")
        }
    }
    #endif
}

extension SettingsScreen {
    enum SettingsNav {
        case advanced
        case appearance
        case jellyfin

        #if DEBUG
        case developer
        #endif
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    SettingsScreen()
        .environmentObject(ApiClient(previewEnabled: true))
}

// swiftlint:enable all
#endif

#if DEBUG
// MARK: - Developer settings

private struct DeveloperSettings: View {
    @Default(.previewMode)
    var previewEnabled: Bool

    @Default(.readOnly)
    var readOnlyEnabled: Bool

    @Default(.restorePlaybackQueue)
    var restorePlaybackQueueEnabled: Bool

    var apiClient: ApiClient

    init(apiClient: ApiClient = .shared) {
        self.apiClient = apiClient
    }

    var body: some View {
        List {
            previewMode()
            readOnlyMode()
            restorePlaybackQueueOption
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

    @ViewBuilder
    private var restorePlaybackQueueOption: some View {
        Toggle(isOn: $restorePlaybackQueueEnabled) {
            Text("Restore playback queue on app restart")
        }
    }
}
#endif
