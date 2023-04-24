import SwiftUI

struct SongsLibraryScreen: View {
    @ObservedObject
    var songRepo: SongRepository

    init(songRepo: SongRepository = .shared) {
        _songRepo = ObservedObject(wrappedValue: songRepo)
    }

    var body: some View {
        Group {
            if songRepo.songs.isEmpty {
                Text("No songs available")
                    .font(.title3)
                    .foregroundColor(.gray)
            } else {
                SongCollection(songs: songRepo.songs.sortByAlbum())
                    .showArtwork()
                    .showArtistName()
                    .listStyle(.plain)
            }
        }
        .navigationTitle("Songs")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem { RefreshButton(mode: .allSongs) }
        }
    }
}

#if DEBUG
struct SongsLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SongsLibraryScreen(
            songRepo: SongRepository(
                store: .previewStore(
                    items: PreviewData.songs,
                    cacheIdentifier: \.uuid
                )
            )
        )
    }
}
#endif
