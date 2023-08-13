import SFSafeSymbols
import SwiftUI

struct ArtistLibraryScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @State
    private var sortBy: SortBy = .name

    var body: some View {
        content
            .navigationTitle("Artists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    RefreshButton(mode: .allArtists)
                    sortByMenu
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if library.artists.isNotEmpty {
            List {
                ForEach(library.artists.sorted(by: sortBy)) { artist in
                    NavigationLink {
                        ArtistDetailScreen(artist: artist)
                    } label: {
                        Label {
                            Text(artist.name)
                                .font(.title2)
                        } icon: {
                            ArtworkComponent(itemId: artist.id)
                                .frame(width: 40, height: 40)
                        }
                        .labelStyle(.titleAndIcon)
                    }
                }
            }
            .listStyle(.plain)
        } else {
            Text("No artists")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Sort menu

    @ViewBuilder
    private var sortByMenu: some View {
        Menu {
            sortByNameButton
        } label: {
            switch sortBy {
            case .name:
                Image(systemSymbol: .textformat)
            }
        }
    }

    @ViewBuilder
    private var sortByNameButton: some View {
        Button {
            sortBy = .name
        } label: {
            Label("Name", systemSymbol: .textformat)
        }
    }
}

#if DEBUG
struct ArtistLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ArtistLibraryScreen()
                .environmentObject(PreviewUtils.libraryRepo)
        }
        .previewDisplayName("With navigation")

        ArtistLibraryScreen()
            .environmentObject(PreviewUtils.libraryRepo)
            .previewDisplayName("Plain")
    }
}
#endif
