import Defaults
import SwiftUI

struct SettingsScreen: View {
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
            ServerStatusComponent()
        }
    }

    @ViewBuilder
    func generalSection() -> some View {
        Section {
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
            DeveloperSettings()
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
        SettingsScreen()
    }
}
#endif

#if DEBUG
// MARK: - Developer settings

private struct DeveloperSettings: View {
    var body: some View {
        List {
            PreviewMode()
        }
        .listStyle(.grouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Developer")
    }
}

private struct PreviewMode: View {
    @Environment(\.api)
    var api

    @Default(.previewMode)
    var previewEnabled: Bool

    var body: some View {
        // swiftlint:disable:next trailing_closure
        Toggle(isOn: $previewEnabled) {
            ListOptionComponent(
                symbol: .eyes,
                text: "Preview mode"
            )
        }
        .onChange(of: previewEnabled, perform: { newValue in
            if newValue {
                api.usePreviewMode()
                return
            }

            Task {
                do {
                    api.useDefaultMode()
                    _ = try await api.performAuth()
                } catch {
                    print("Failed to switch to default mode: \(error)")
                }
            }
        })
    }
}
#endif
