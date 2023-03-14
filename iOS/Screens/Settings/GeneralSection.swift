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
            HStack(spacing: 7) {
                Image(systemSymbol: .eyes)
                Text("Preview mode")
            }
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

    var body: some View {
        Button {
            // TODO: add confirm alert and success/fail alert
            self.onSubmit()
        } label: {
            Image(systemSymbol: .trash)
            Text("Purge all caches")
        }
        .buttonStyle(.plain)
        .foregroundColor(.red)
    }

    private func onSubmit() {
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
