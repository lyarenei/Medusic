import SwiftUI

struct SongsLibraryScreen: View {
    @EnvironmentObject
    private var songRepo: SongRepository

    var body: some View {
        content
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem { RefreshButton(mode: .allSongs) }
            }
    }

    @ViewBuilder
    private var content: some View {
        if songRepo.songs.isNotEmpty {
            List {
                SongCollection(songs: songRepo.songs.sortByAlbum())
                    .showArtwork()
                    .showArtistName()
                    .collectionType(.list)
            }
            .listStyle(.plain)
        } else {
            Text("No songs available")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }
}

#if DEBUG
struct SongsLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SongsLibraryScreen()
            .previewDisplayName("Default")
            .environmentObject(
                SongRepository(
                    store: .previewStore(
                        items: PreviewData.songs,
                        cacheIdentifier: \.uuid
                    )
                )
            )

        SongsLibraryScreen()
            .previewDisplayName("Empty")
            .environmentObject(
                SongRepository(
                    store: .previewStore(
                        items: [],
                        cacheIdentifier: \.uuid
                    )
                )
            )
    }
}
#endif
