import Boutique
import DebouncedOnChange
import Defaults
import Kingfisher
import SFSafeSymbols
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
            AppearanceSettings()
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
            AdvancedSettings()
        } label: {
            ListOptionComponent(
                symbol: .wrenchAndScrewdriver,
                text: "Advanced"
            )
        }
    }

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
}

#if DEBUG
struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}
#endif

// MARK: - Appearance settings

private struct AppearanceSettings: View {
    var body: some View {
        List {
            AlbumDisplayOption()
        }
        .listStyle(.grouped)
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum AlbumDisplayMode: String, Defaults.Serializable {
    case asList
    case asTiles
}

private struct AlbumDisplayOption: View {
    @Default(.albumDisplayMode)
    var selectedOption: AlbumDisplayMode

    var body: some View {
        Picker("Show albums as", selection: $selectedOption) {
            Text("List").tag(AlbumDisplayMode.asList)
            Text("Tiles (default)").tag(AlbumDisplayMode.asTiles)
        }
        .pickerStyle(.menu)
    }
}

// MARK: - Advanced settings

private struct AdvancedSettings: View {
    var body: some View {
        List {
            PurgeCaches()
        }
        .listStyle(.grouped)
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PurgeCaches: View {
    @Stored(in: .albums)
    private var albums: [Album]

    @Stored(in: .songs)
    private var songs: [Song]

    @State
    private var showPurgeCacheConfirm = false

    var body: some View {
        Button {
            showPurgeCacheConfirm = true
        } label: {
            ListOptionComponent(
                symbol: .trash,
                text: "Purge all caches"
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(.red)
        .alert(isPresented: $showPurgeCacheConfirm, content: {
            Alert(
                title: Text("Purge all caches"),
                message: Text("This will remove all metadata, images and downloads"),
                primaryButton: .destructive(
                    Text("Purge"),
                    action: { self.purgeCaches() }
                ),
                secondaryButton: .default(
                    Text("Cancel"),
                    action: { showPurgeCacheConfirm = false }
                )
            )
        })
    }

    private func purgeCaches() {
        Kingfisher.ImageCache.default.clearMemoryCache()
        Kingfisher.ImageCache.default.clearDiskCache()

        Task {
            do {
                try await self.$albums.removeAll()
                try await self.$songs.removeAll()
                try FileRepository.shared.removeAllFiles()
            } catch {
                print("Purging caches failed: \(error)")
            }
        }
    }
}

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
