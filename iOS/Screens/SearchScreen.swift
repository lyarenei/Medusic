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
                .listStyle(.plain)
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
                sectionView("Albums")
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
                sectionView("Songs")
            }
        }
    }

    @ViewBuilder
    private func sectionView(_ title: String) -> some View {
        ZStack {
            Color.systemGroupedBackground

            HStack {
                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(.darkGray)
                    .padding(.leading)
                    .padding(.vertical, 10)

                Spacer()
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .overlay {
            Rectangle()
                .stroke(style: .init(lineWidth: 0.2))
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
