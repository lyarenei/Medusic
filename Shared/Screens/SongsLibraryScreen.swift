import SwiftUI

struct SongsLibraryScreen: View {
    @ObservedObject
    var songRepo: SongRepository

    init(songRepo: SongRepository = .shared) {
        _songRepo = ObservedObject(wrappedValue: songRepo)
    }

    var body: some View {
        content()
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem { RefreshButton(mode: .allSongs) }
            }
    }

    @ViewBuilder
    private func content() -> some View {
        if songRepo.songs.isEmpty {
            Text("No songs available")
                .font(.title3)
                .foregroundColor(.gray)
        } else {
            List {
                SongCollection(songs: songRepo.songs.sortByAlbum())
                    .showArtwork()
                    .showArtistName()
                    .collectionType(.list)
            }
            .listStyle(.plain)
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
        .previewDisplayName("Default")

        SongsLibraryScreen(
            songRepo: SongRepository(
                store: .previewStore(
                    items: [],
                    cacheIdentifier: \.uuid
                )
            )
        )
        .previewDisplayName("Empty")
    }
}
#endif
