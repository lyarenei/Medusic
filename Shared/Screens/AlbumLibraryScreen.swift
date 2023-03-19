import Defaults
import JellyfinAPI
import SwiftUI
import SwiftUIBackports

struct AlbumLibraryScreen: View {
    @StateObject
    private var albumRepo = AlbumRepository(store: .albums)

    @State
    private var albums: [Album]?

    @Default(.albumDisplayMode)
    private var albumDisplayMode: AlbumDisplayMode

    var body: some View {
        ZStack {
            switch albumDisplayMode {
            case .asList:
                AlbumList(albums: albums)
            default:
                ScrollView(.vertical) {
                    AlbumTileList(albums: albums)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
            }
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
    static var albums: [Album] = [
        Album(
            uuid: "1",
            name: "Nice album name",
            artistName: "Album artist",
            isFavorite: true
        ),
        Album(
            uuid: "2",
            name: "Album with very long name that one gets tired reading it",
            artistName: "Unamusing artist",
            isDownloaded: true
        ),
    ]

    static var previews: some View {
        AlbumLibraryScreen(albums: albums)
    }
}
#endif
