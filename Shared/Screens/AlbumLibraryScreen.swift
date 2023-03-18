import JellyfinAPI
import SwiftUI

struct AlbumLibraryScreen: View {
    @StateObject
    private var albumRepo = AlbumRepository(store: .albums)

    @State
    private var albums: [Album]?

    var body: some View {
        ScrollView(.vertical) {
            if let allAlbums = albums {
                AlbumTileListComponent(albums: allAlbums)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Albums")
        .onAppear { Task { self.albums = await self.albumRepo.getAlbums() }}
    }
}

#if DEBUG
struct AlbumLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlbumLibraryScreen()
            .environment(\.api, .init())
    }
}
#endif
