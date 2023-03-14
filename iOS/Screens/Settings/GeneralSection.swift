import Boutique
import Defaults
import Kingfisher
import SwiftUI

extension SettingsScreen {
    struct GeneralSection: View {
        var body: some View {
            Section(
                header: Text("General"),
                content: {
                    PreviewModeToggle()

                    NavigationLink {
                        // TODO: advanced settings view
                    } label: {
                        ListOptionComponent(
                            symbol: .wrenchAndScrewdriver,
                            text: "Advanced"
                        )
                    }
                    .disabled(true)

                    PurgeCaches()
                }
            )
        }
    }
}

private struct PreviewModeToggle: View {
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

            do {
                api.useDefaultMode()
                try api.performAuth()
            } catch {
                print("Failed to switch to default mode: \(error)")
            }
        })
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
            } catch {
                print("Purging caches failed: \(error)")
            }
        }
    }
}

#if DEBUG
struct GeneralSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.api, .init())
    }
}
#endif
