import JellyfinAPI
import OSLog
import SwiftUI

struct AlbumLibraryScreen: View {
    @EnvironmentObject
    private var albumRepo: AlbumRepository

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
        if albumRepo.albums.isNotEmpty {
            List {
                AlbumCollection(albums: albumRepo.albums.consistent)
                    .forceMode(.asList)
            }
            .listStyle(.plain)
        } else {
            Text("No albums available")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }
}

#if DEBUG
struct AlbumLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlbumLibraryScreen()
            .environmentObject(
                AlbumRepository(
                    store: .previewStore(
                        items: PreviewData.albums,
                        cacheIdentifier: \.uuid
                    )
                )
            )
    }
}
#endif
