import SFSafeSymbols
import SwiftUI

struct LibraryScreen: View {
    @StateObject
    private var controller: LibraryController = .init()

    init(_ controller: LibraryController = .init()) {
        self._controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    LibraryNavigationItems(controller)
                        .padding([.top, .leading, .trailing], 10)

                    Text("Favorite albums")
                        .font(.title)
                        .bold()
                        .padding(.leading, 15)
                        .padding(.top, 25)
                        .padding(.bottom, -1)

                    AlbumCollection(
                        albums: controller.favoriteAlbums
                    )
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .buttonStyle(.plain)
                }
                .onAppear { self.controller.setFavoriteAlbums() }
            }
            .navigationTitle("Library")
        }
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
