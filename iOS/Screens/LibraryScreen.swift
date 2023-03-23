import SFSafeSymbols
import SwiftUI

struct LibraryScreen: View {
    @StateObject
    private var controller: LibraryController

    init () {
        self._controller = StateObject(wrappedValue: LibraryController())
    }

    init(_ controller: LibraryController) {
        self._controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 15) {
                        LibraryNavigationItems(controller)
                            .padding(.top, 10)

                        Text("Favorite albums")
                            .font(.title)
                            .bold()
                            .padding(.leading, 5)
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
            }
            .listStyle(.plain)
            .navigationTitle("Library")

            // TODO: fix broken rendering
            AlbumList(albums: controller.favoriteAlbums)
        }
        .onAppear { self.controller.setFavoriteAlbums() }
    }
}

#if DEBUG
struct LibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        LibraryScreen(LibraryController(
            albumRepo: AlbumRepository(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)),
            songRepo: SongRepository(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        ))
    }
}
#endif

// MARK: - Navigation entry

private struct NavigationEntry<Content: View>: View {
    var destination: Content
    var text: String
    var symbol: SFSymbol

    init(
        @ViewBuilder destination: () -> Content,
        text: String,
        symbol: SFSymbol
    ) {
        self.destination = destination()
        self.text = text
        self.symbol = symbol
    }

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemSymbol: symbol)
                    .foregroundColor(Color.accentColor)
                    .frame(minWidth: 25)

                Text(text)

                Spacer(minLength: 10)

                Image(systemSymbol: .chevronRight)
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
            .frame(height: 40)
            .buttonStyle(.plain)
            .font(.title3)
        }
        .padding(.leading, 10)
        .padding(.trailing, 15)
    }
}

// MARK: - Navigation items

private struct LibraryNavigationItems: View {
    @StateObject
    private var controller: LibraryController

    init(_ controller: LibraryController) {
        self._controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        VStack(alignment: .leading) {
            NavigationEntry(
                destination: { },
                text: "Playlists",
                symbol: .musicNoteList
            )
            .disabled(true)

            Divider()

            NavigationEntry(
                destination: { },
                text: "Artists",
                symbol: .musicMic
            )
            .disabled(true)

            Divider()

            NavigationEntry(
                destination: { AlbumLibraryScreen() },
                text: "Albums",
                symbol: .squareStack
            )

            Divider()

            NavigationEntry(
                destination: { SongsLibraryScreen() },
                text: "Songs",
                symbol: .musicNote
            )

            Divider()

            NavigationEntry(
                destination: { },
                text: "Downloads",
                symbol: .arrowDownApp
            )
            .disabled(true)

            Divider()
        }
    }
}
