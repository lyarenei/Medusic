import SwiftUI
import JellyfinAPI

struct AlbumListView: View {

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
                            AlbumView(album: album)
                        },
                        label: {
                            AlbumTileComponent(album: album)
                        }
                    )
                    .buttonStyle(.plain)
                }
            }
            .font(.largeTitle)
        }
        .navigationTitle("Albums")
        .onAppear {
            Task {
                do {
                    albums = try await api.albumService.getAlbums()
                } catch {
                    print("Failed to fetch albums.")
                }
            }
        }
    }
}

#if DEBUG
struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumListView()
            .environment(\.api, .preview)
    }
}
#endif
