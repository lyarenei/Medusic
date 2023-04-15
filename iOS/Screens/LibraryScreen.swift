import SFSafeSymbols
import SwiftUI

struct LibraryScreen: View {
    @ObservedObject
    var albumRepo: AlbumRepository

    init(albumRepo: AlbumRepository = .shared) {
        _albumRepo = ObservedObject(wrappedValue: albumRepo)
    }

    var body: some View {
        NavigationView {
            List {
                navLink(for: "Playlists", to: EmptyView(), icon: .musicNoteList)
                    .disabled(true)

                navLink(for: "Artists", to: EmptyView(), icon: .musicMic)
                    .disabled(true)

                navLink(for: "Albums", to: AlbumLibraryScreen(), icon: .squareStack)
                navLink(for: "Songs", to: SongsLibraryScreen(), icon: .musicNote)

                favoritesTitle()
                favoritesContent(albumRepo.albums.favorite.consistent)
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .listStyle(.plain)
            .toolbar {
                ToolbarItem { RefreshButton(mode: .all) }
            }
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    func navLink(for name: String, to dst: some View, icon: SFSymbol) -> some View {
        NavigationLink(destination: dst) {
            HStack(spacing: 15) {
                Image(systemSymbol: icon)
                    .foregroundColor(.accentColor)
                    .frame(minWidth: 25)

                Text(name)
            }
            .buttonStyle(.plain)
            .font(.title2)
        }
        .contentShape(Rectangle())
        .frame(height: 40)
    }

    @ViewBuilder
    func favoritesTitle() -> some View {
        Text("Favorite albums")
            .font(.title)
            .bold()
            .padding(.top, 30)
    }

    @ViewBuilder
    func favoritesContent(_ albums: [Album]) -> some View {
        ForEach(albums) { album in
            NavigationLink {
                AlbumDetailScreen(for: album)
            } label: {
                AlbumListRowComponent(album: album)
            }
            .padding(.vertical, 7)
        }
    }
}

#if DEBUG
struct LibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        LibraryScreen(albumRepo: .init(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)))

        LibraryScreen(albumRepo: .init(store: .previewStore(items: [], cacheIdentifier: \.uuid)))
            .previewDisplayName("Empty library")
    }
}
#endif
