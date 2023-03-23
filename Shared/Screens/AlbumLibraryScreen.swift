import Defaults
import JellyfinAPI
import SwiftUI
import SwiftUIBackports

struct AlbumLibraryScreen: View {
    @StateObject
    private var controller: AlbumLibraryController

    init () {
        self._controller = StateObject(wrappedValue: AlbumLibraryController())
    }

    init(_ controller: AlbumLibraryController) {
        self._controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        ZStack {
            AlbumList(albums: controller.albums)
                .listStyle(.plain)
        }
        .navigationTitle("Albums")
        .onAppear { self.controller.setAlbums() }
        .backport.refreshable { await self.controller.doRefresh() }
    }
}

#if DEBUG
struct AlbumLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlbumLibraryScreen(AlbumLibraryController(
            albumRepo: AlbumRepository(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)),
            songRepo: SongRepository(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        ))
    }
}
#endif
