import SwiftUI
import SwiftUIBackports

struct SongsLibraryScreen: View {
    @StateObject
    private var songRepo = SongRepository(store: .songs)

    @State
    private var songs: [Song] = []

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                // TODO: play/shuffle actions

                ForEach(songs) { song in
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
        .backport.task(priority: .background) {
            self.songs = await self.songRepo.getSongs().sortByAlbum()
        }
    }
}

#if DEBUG
struct SongsLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SongsLibraryScreen()
            .environment(\.api, .init())
    }
}
#endif
