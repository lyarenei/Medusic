import SwiftUI
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
        .padding(.leading, 15)
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
                destination: { AlbumListView() },
                text: "Albums",
                symbol: .squareStack
            )

            Divider()

            NavigationEntry(
                destination: {},
                text: "Songs",
                symbol: .musicNote
            )
            .disabled(true)

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

struct LibraryView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LibraryNavigationItems()
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            }
            .navigationTitle("Library")
        }
    }
}

#if DEBUG
struct LibraryNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
#endif
