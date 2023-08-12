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
            Text("No songs available")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private func songRow(for song: Song) -> some View {
        HStack {
            ArtworkComponent(itemId: song.parentId)
                .frame(width: 38, height: 38)

            VStack(alignment: .leading) {
                Text(song.name)
                    .lineLimit(1)

                Text("song.artistName")
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
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
