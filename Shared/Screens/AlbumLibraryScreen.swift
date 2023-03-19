import JellyfinAPI
import SwiftUI
import SwiftUIBackports

struct AlbumLibraryScreen: View {
    @StateObject
    private var albumRepo = AlbumRepository(store: .albums)

    @State
    private var albums: [Album]?

    var body: some View {
        ScrollView(.vertical) {
            AlbumTileListComponent(albums: albums)
                .padding(.leading, 10)
                .padding(.trailing, 10)
        }
        .navigationTitle("Albums")
        .onAppear { Task { await self.setAlbums() }}
        .backport.refreshable { await self.doRefresh() }
    }

    private func setAlbums() async {
        self.albums = await self.albumRepo.getAlbums()
    }

    private func doRefresh() async {
        do {
            try await self.albumRepo.refresh()
            await self.setAlbums()
        } catch {
            print("Refreshing albums failed", error)
        }
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
