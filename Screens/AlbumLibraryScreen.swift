import JellyfinAPI
import OSLog
import SwiftUI

struct AlbumLibraryScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    var body: some View {
        content
            .navigationTitle("Albums")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem { RefreshButton(mode: .allAlbums) }
            }
    }

    @ViewBuilder
    private var content: some View {
        if library.albums.isNotEmpty {
            List {
                AlbumCollection(albums: library.albums)
                    .forceMode(.asList)
            }
            .listStyle(.plain)
        } else {
            Text("No albums")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }
}

#if DEBUG
struct AlbumLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AlbumLibraryScreen()
                .environmentObject(PreviewUtils.libraryRepo)
        }
    }
}
#endif
