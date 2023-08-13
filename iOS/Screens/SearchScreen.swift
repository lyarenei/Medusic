import SwiftUI
import SwiftUIX

struct SearchScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @State
    private var query: String = .empty

    @State
    private var searchQuery: String = .empty

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $query)
                    .placeholder("Search")
                    .isInitialFirstResponder(true)
                    .showsCancelButton(true)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .onChange(of: query, debounceTime: 0.5) { newValue in
                        searchQuery = newValue
                    }

                let filteredAlbums = library.albums.filter { $0.name.containsIgnoreCase(searchQuery) }
                let filteredSongs = library.songs.filter { $0.name.containsIgnoreCase(searchQuery) }

                List {
                    albumResults(filteredAlbums)
                    songResults(filteredSongs)
                }
                .listStyle(.grouped)
            }
            .navigationTitle(String.empty)
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
        NavigationStack {
            SearchScreen()
        }
        .environmentObject(PreviewUtils.libraryRepo)
    }
}
#endif
