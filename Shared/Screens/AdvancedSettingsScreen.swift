import Boutique
import Kingfisher
import SwiftUI

struct AdvancedSettingsScreen: View {
    var body: some View {
        List {
            PurgeCaches()
        }
        .listStyle(.grouped)
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct AdvancedSettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsScreen()
    }
}
#endif

private struct PurgeCaches: View {
    @Stored(in: .albums)
    var albums: [Album]

    @Stored(in: .songs)
    var songs: [Song]

    @State
    var showPurgeCacheConfirm = false

    var body: some View {
        // swiftlint:disable:next trailing_closure
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
                primaryButton: .destructive(Text("Purge")) { purgeCaches() },
                secondaryButton: .default(Text("Cancel")) { showPurgeCacheConfirm = false }
            )
        })
    }

    func purgeCaches() {
        Kingfisher.ImageCache.default.clearMemoryCache()
        Kingfisher.ImageCache.default.clearDiskCache()

        Task {
            do {
                try await $albums.removeAll()
                try await $songs.removeAll()
                try FileRepository.shared.removeAllFiles()
            } catch {
                print("Purging caches failed: \(error)")
            }
        }
    }
}
