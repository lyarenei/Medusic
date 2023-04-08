import JellyfinAPI
import OSLog
import SwiftUI
import SwiftUIBackports

struct AlbumLibraryScreen: View {
    @ObservedObject
    var albumRepo: AlbumRepository

    init(albumRepo: AlbumRepository = .shared) {
        _albumRepo = ObservedObject(wrappedValue: albumRepo)
    }

    var body: some View {
        ScrollView {
            AlbumCollection(albums: albumRepo.albums)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .buttonStyle(.plain)
        }
        .navigationTitle("Albums")
        .navigationBarTitleDisplayMode(.large)
        .backport.refreshable { await self.doRefresh() }
    }

    func doRefresh() async {
        Logger.library.debug("Requested album refresh from album library")
        do {
            try await self.albumRepo.refresh()
        } catch {
            Logger.library.info("Album refresh failed: \(error.localizedDescription)")
        }
    }
}

#if DEBUG
struct AlbumLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlbumLibraryScreen(albumRepo: .init(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)))
    }
}
#endif
