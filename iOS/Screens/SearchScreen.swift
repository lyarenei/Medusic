import SwiftUI
import SwiftUIX

struct SearchScreen: View {
    @ObservedObject
    var albumRepo: AlbumRepository

    @ObservedObject
    var songRepo: SongRepository

    @State
    var query = ""

    @State
    var searchQuery = ""

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
                .onChange(of: query, debounceTime: 0.5) { newValue in
                    searchQuery = newValue
                }

            let filteredAlbums = albumRepo.albums.filter { $0.name.containsIgnoreCase(searchQuery) }
            let filteredSongs = songRepo.songs.filter { $0.name.containsIgnoreCase(searchQuery) }

            List {
                albumResults(filteredAlbums)
                songResults(filteredSongs)
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private func albumResults(_ albums: [Album]) -> some View {
        if albums.isNotEmpty {
            Text("Albums")
                .bold()
                .font(.title2)

            AlbumCollection(albums: albums)
        }
    }

    @ViewBuilder
    private func songResults(_ songs: [Song]) -> some View {
        if songs.isNotEmpty {
            Text("Songs")
                .bold()
                .font(.title2)
                .padding(.top, 30)

            SongCollection(songs: songs)
                .collectionType(.list)
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
