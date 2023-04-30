import JellyfinAPI
import OSLog
import SwiftUI

struct AlbumLibraryScreen: View {
    @ObservedObject
    var albumRepo: AlbumRepository

    init(albumRepo: AlbumRepository = .shared) {
        _albumRepo = ObservedObject(wrappedValue: albumRepo)
    }

    var body: some View {
        List {
            AlbumCollection(albums: albumRepo.albums)
                .forceMode(.asList)
        }
        .navigationTitle("Albums")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem { RefreshButton(mode: .allAlbums) }
        }
    }
}

#if DEBUG
struct AlbumLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlbumLibraryScreen(
            albumRepo: .init(
                store: .previewStore(
                    items: PreviewData.albums,
                    cacheIdentifier: \.uuid
                )
            )
        )
    }
}
#endif
