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
        NavigationView {
            VStack {
                SearchBar(text: $query)
                    .placeholder("Search")
                    .isInitialFirstResponder(true)
                    .showsCancelButton(true)
                    .onChange(of: query, debounceTime: 0.5) { newValue in
                        searchQuery = newValue
                    }

                let filteredAlbums = albumRepo.albums.filter { $0.name.containsIgnoreCase(searchQuery) }
                let filteredSongs = songRepo.songs.filter { $0.name.containsIgnoreCase(searchQuery) }

                List {
                    albumResults(filteredAlbums)
                    songResults(filteredSongs)
                }
                .listStyle(.grouped)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private func albumResults(_ albums: [Album]) -> some View {
        if albums.isNotEmpty {
            Section {
                AlbumCollection(albums: albums)
                    .forceMode(.asList)
            } header: {
                Text("Albums")
            }
        }
    }

    @ViewBuilder
    private func songResults(_ songs: [Song]) -> some View {
        if songs.isNotEmpty {
            Section {
                SongCollection(songs: songs)
                    .collectionType(.list)
                    .showAlbumName()
                    .showArtwork()
            } header: {
                Text("Songs")
            }
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
