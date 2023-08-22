import SFSafeSymbols
import SwiftUI

struct ArtistLibraryScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @State
    private var sortBy: UserSortBy = .name

    let artists: [Artist]

    var body: some View {
        content
            .navigationTitle("Artists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    RefreshButton(mode: .allArtists)
                    SortMenuButton(sortBy: $sortBy)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if artists.isNotEmpty {
            List {
                ForEach(artists.sorted(by: sortBy)) { artist in
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
}

#if DEBUG
struct ArtistLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ArtistLibraryScreen(artists: PreviewData.artists)
                .environmentObject(PreviewUtils.libraryRepo)
        }
        .previewDisplayName("With navigation")

        ArtistLibraryScreen(artists: PreviewData.artists)
            .environmentObject(PreviewUtils.libraryRepo)
            .previewDisplayName("Plain")
    }
}
#endif
