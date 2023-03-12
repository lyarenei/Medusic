import SwiftUI

struct SongsLibraryScreen: View {
    @Environment(\.api)
    var api

    @State
    private var songs: [Song] = []

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(songs) { song in
                    SongEntryComponent(
                        song: song,
                        showAlbumOrder: false,
                        showArtwork: true,
                        showActions: true
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
        .onAppear {
            Task {
                do {
                    songs = try await api.songService.getSongs(with: "0f0edfcf31d64740bd577afe8e94b752")
                } catch {
                    print("Failed to fetch songs: \(error)")
                }
            }
        }
    }
}

#if DEBUG
struct SongsLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SongsLibraryScreen()
            .environment(\.api, .preview)
    }
}
#endif
