import SwiftUI
import Combine
import SFSafeSymbols

private struct NavigationEntry<Content: View>: View {

    var destination: Content
    var text: String
    var symbol: SFSymbol

    init(
        @ViewBuilder
        destination: () -> Content,
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

private struct LibraryNavigationItems: View {
    var body: some View {
        VStack(alignment: .leading) {
            NavigationEntry(
                destination: {},
                text: "Playlists",
                symbol: .musicNoteList
            )
            .disabled(true)

            Divider()

            NavigationEntry(
                destination: {},
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
                destination: {},
                text: "Downloads",
                symbol: .arrowDownApp
            )
            .disabled(true)

            Divider()
        }
    }
}

struct LibraryScreen: View {

    @Environment(\.api)
    var api

    @State
    private var favoriteAlbums: [Album] = []

    @State
    private var lifetimeCancellables: Cancellables = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 15) {
                        LibraryNavigationItems()
                            .padding(.top, 10)

                        Text("Favorite albums")
                            .font(.title)
                            .bold()
                            .padding(.leading, 5)
                    }

                    AlbumTileListComponent(albums: favoriteAlbums)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
            }
            .navigationTitle("Library")
        }
        .onAppear {
            api.albumService.getAlbums(for: "0f0edfcf31d64740bd577afe8e94b752")
                .catch { error -> Empty<[Album], Never> in
                    print("Failed to fetch albums:", error)
                    return Empty()
                }
                .assign(to: \.favoriteAlbums, on: self)
                .store(in: &lifetimeCancellables)
        }
    }
}

#if DEBUG
struct LibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        LibraryScreen()
    }
}
#endif
