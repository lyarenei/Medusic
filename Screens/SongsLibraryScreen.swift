import SwiftUI

struct SongsLibraryScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    let songs: [Song]

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
        if songs.isNotEmpty {
            List {
                SongCollection(songs: songs)
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
            SongsLibraryScreen(songs: PreviewData.songs)
        }
        .previewDisplayName("Default")
        .environmentObject(PreviewUtils.libraryRepo)

        NavigationStack {
            SongsLibraryScreen(songs: PreviewData.songs)
        }
        .previewDisplayName("Empty")
        .environmentObject(PreviewUtils.libraryRepoEmpty)
    }
}
#endif
