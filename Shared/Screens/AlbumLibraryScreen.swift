import SwiftUI
import JellyfinAPI

struct AlbumLibraryScreen: View {

    @Environment(\.api)
    var api

    @State
    private var albums: [Album] = []
    
    var body: some View {
        let layout = [GridItem(.flexible()), GridItem(.flexible())]
        
        ScrollView(.vertical) {
            LazyVGrid(columns: layout) {
                ForEach(albums) { album in
                    NavigationLink(
                        destination: {
                            AlbumDetailScreen(album: album)
                        },
                        label: {
                            AlbumTileComponent(album: album)
                        }
                    )
                    .buttonStyle(.plain)
                }
            }
            .font(.largeTitle)
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
        .navigationTitle("Albums")
        .onAppear {
            Task {
                do {
                    albums = try await api.albumService.getAlbums(for: "0f0edfcf31d64740bd577afe8e94b752")
                } catch {
                    print("Failed to fetch albums.")
                }
            }
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
