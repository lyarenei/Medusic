import SwiftUI
import SwiftUIBackports

struct SongsLibraryScreen: View {
    @Environment(\.api)
    var api

    @State
    private var songs: [Song] = []

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                // TODO: play/shuffle actions

                ForEach(songs) { song in
                    SongEntryComponent(
                        song: song,
                        showAlbumOrder: false,
                        showArtwork: true,
                        showActions: true,
                        showAlbumName: true
                    )
                    .font(.title3)
                    .padding(.leading)
                    .padding(.trailing)
                    .frame(height: 50)

                    Divider()
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
            }
        }
        .navigationTitle("Songs")
        .backport.task(priority: .background) {
            do {
                songs = try await api.services.songService.getSongs()
            } catch {
                print("Failed to fetch songs: \(error)")
            }
        }
    }
}

#if DEBUG
struct SongsLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SongsLibraryScreen()
            .environment(\.api, .init())
    }
}
#endif
