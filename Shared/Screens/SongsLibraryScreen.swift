import SwiftUI

struct SongsLibraryScreen: View {
    @ObservedObject
    var songRepo: SongRepository

    init(songRepo: SongRepository = .shared) {
        _songRepo = ObservedObject(wrappedValue: songRepo)
    }

    var body: some View {
        ScrollView(.vertical) {
            SongCollection(
                songs: songRepo.songs,
                showAlbumOrder: false,
                showArtwork: true,
                showAction: true,
                showArtistName: true
            )
        }
        .navigationTitle("Songs")
        .navigationBarTitleDisplayMode(.large)
    }
}

#if DEBUG
struct SongsLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SongsLibraryScreen(songRepo: SongRepository(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid)))
    }
}
#endif
