import SwiftUI
import SwiftUIX

struct SearchScreen: View {
    @ObservedObject
    var albumRepo: AlbumRepository

    @ObservedObject
    var songRepo: SongRepository

    @State
    var query = ""

    init(
        albumRepo: AlbumRepository = .shared,
        songRepo: SongRepository = .shared
    ) {
        self._albumRepo = ObservedObject(wrappedValue: albumRepo)
        self._songRepo = ObservedObject(wrappedValue: songRepo)
    }

    var body: some View {
        VStack {
            SearchBar(text: $query)
                .placeholder("Search")

            let filteredAlbums = albumRepo.albums.filter { $0.name.containsIgnoreCase(query) }
            let filteredSongs = songRepo.songs.filter { $0.name.containsIgnoreCase(query) }

            List {
                if filteredAlbums.isNotEmpty {
                    Text("Albums")
                        .bold()
                        .font(.title2)

                    AlbumCollection(albums: filteredAlbums)
                }

                if filteredSongs.isNotEmpty {
                    Text("Songs")
                        .bold()
                        .font(.title2)
                        .padding(.top, 30)

                    SongCollection(songs: filteredSongs)
                        .collectionType(.list)
                }
            }
            .listStyle(.plain)
        }
    }
}

#if DEBUG
struct SearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        SearchScreen(
            albumRepo: .init(
                store: .previewStore(
                    items: PreviewData.albums,
                    cacheIdentifier: \.uuid
                )
            ),
            songRepo: .init(
                store: .previewStore(
                    items: PreviewData.songs,
                    cacheIdentifier: \.uuid
                )
            )
        )
    }
}
#endif
