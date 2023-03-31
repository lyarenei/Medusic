import SwiftUI
import SwiftUIBackports

struct SongsLibraryScreen: View {
    @StateObject
    private var controller: SongLibraryController

    init () {
        self._controller = StateObject(wrappedValue: SongLibraryController())
    }

    init(_ controller: SongLibraryController) {
        self._controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        ScrollView(.vertical) {
            SongCollection(
                songs: controller.songs,
                showAlbumOrder: false,
                showArtwork: true,
                showAction: true,
                showArtistName: true
            )
        }
        .navigationTitle("Songs")
        .onAppear { controller.setSongs() }
    }
}

#if DEBUG
struct SongsLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SongsLibraryScreen(SongLibraryController(
            albumRepo: AlbumRepository(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)),
            songRepo: SongRepository(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        ))
    }
}
#endif
