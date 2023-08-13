import SwiftUI

struct SongsLibraryScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    var body: some View {
        content
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem { RefreshButton(mode: .allSongs) }
            }
    }

    @ViewBuilder
    private var content: some View {
        if library.songs.isNotEmpty {
            List {
                SongCollection(songs: library.songs)
                    .showArtwork()
                    .showArtistName()
            }
            .listStyle(.plain)
        } else {
            Text("No songs")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }
}

#if DEBUG
struct SongsLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SongsLibraryScreen()
        }
        .previewDisplayName("Default")
        .environmentObject(PreviewUtils.libraryRepo)

        NavigationStack {
            SongsLibraryScreen()
        }
        .previewDisplayName("Empty")
        .environmentObject(PreviewUtils.libraryRepoEmpty)
    }
}
#endif
