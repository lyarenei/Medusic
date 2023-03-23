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
            LazyVStack {
                // TODO: play/shuffle actions

                ForEach(controller.songs) { song in
                    SongEntryComponent(
                        song: song,
                        showAlbumOrder: false,
                        showArtwork: true,
                        showActions: true,
                        showAlbumName: true
                    )
                    .font(.title3)
                    .padding(.leading)
                    .padding(.trailing)
                    .frame(height: 50)

                    Divider()
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
            }
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
