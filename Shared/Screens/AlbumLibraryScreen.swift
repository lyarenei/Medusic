import SwiftUI
import Combine
import JellyfinAPI

struct AlbumLibraryScreen: View {

    @Environment(\.api)
    var api

    @State
    private var albums: [Album] = []

    @State
    private var lifetimeCancellables: Cancellables = []
    
    var body: some View {
        ScrollView(.vertical) {
            AlbumTileListComponent(albums: albums)
                .padding(.leading, 10)
                .padding(.trailing, 10)
        }
        .navigationTitle("Albums")
        .onAppear {
            api.albumService.getAlbums(for: "0f0edfcf31d64740bd577afe8e94b752")
                .catch { error -> Just<[Album]> in
                    print("Failed to fetch albums:", error)
                    return Just([])
                }
                .assign(to: \.albums, on: self)
                .store(in: &lifetimeCancellables)
        }
    }
}

#if DEBUG
struct AlbumLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlbumLibraryScreen()
            .environment(\.api, .preview)
    }
}
#endif
