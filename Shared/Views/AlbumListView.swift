import SwiftUI
import JellyfinAPI

struct AlbumListView: View {

    @Environment(\.api)
    var api
    
    @State
    private var isActive = false

    @State
    private var albums: [AlbumInfo] = []
    
    var navTitle: String
    
    var body: some View {
        let layout = [GridItem(.adaptive(minimum: 170, maximum: 170))]
        
        ScrollView(.vertical) {
            LazyVGrid(columns: layout) {
                ForEach(albums) { album in
                    NavigationLink(
                        isActive: $isActive,
                        destination: {
                            AlbumView(
                                albumName: album.name ?? "unnamed",
                                artistName: album.albumArtists?.joined(separator: ", ") ?? "nobody"
                            )
                        },
                        label: {
                            AlbumTile(
                                albumName: album.name ?? "unnamed",
                                artistName: album.albumArtists?.joined(separator: ", ") ?? "nobody"
                            )
                        }
                    )
                    .buttonStyle(.plain)
                }
            }
            .font(.largeTitle)
        }
        .onAppear {
            Task {
                do {
                    albums = try await api.albumService.getAlbums()
                } catch {
                    print("Failed to fetch albums.")
                }
            }
        }
        .navigationTitle(navTitle)
    }
}

#if DEBUG
struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumListView(navTitle: "Navigation Title")
            .environment(\.api, .preview)
    }
}
#endif
