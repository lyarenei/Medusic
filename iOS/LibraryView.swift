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
    }
}

private struct NavDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 10)
            .padding(.trailing, 10)
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
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .disabled(true)

            NavDivider()

            NavigationEntry(
                destination: {},
                text: "Artists",
                symbol: .musicMic
            )
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .disabled(true)

            NavDivider()

            NavigationEntry(
                destination: { AlbumListView() },
                text: "Albums",
                symbol: .squareStack
            )
                .padding(.leading, 15)
                .padding(.trailing, 15)

            NavDivider()

            NavigationEntry(
                destination: {},
                text: "Songs",
                symbol: .musicNote
            )
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .disabled(true)

            NavDivider()

            NavigationEntry(
                destination: {},
                text: "Downloads",
                symbol: .arrowDownApp
            )
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .disabled(true)

            NavDivider()
        }
    }
}

struct LibraryView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    LibraryNavigationItems()
                        .padding(.top, 10)
                }

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
