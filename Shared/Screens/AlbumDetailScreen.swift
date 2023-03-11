import Kingfisher
import SFSafeSymbols
import SwiftUI

private struct AlbumHeading: View {
    var album: Album

    var body: some View {
        VStack {
            ArtworkComponent(itemId: album.id)
                .frame(width: 230, height: 230)

            Text(album.name)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text(album.artistName)
                .font(.title2)
                .multilineTextAlignment(.center)
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

private struct AlbumActions: View {
    var body: some View {
        HStack {
            Button {
                // Album play action
            } label: {
                Image(systemSymbol: .playFill)
                Text("Play")
            }
            .frame(width: 120, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
            .disabled(true)

            Button {
                // Album shuffle play action
            } label: {
                Image(systemSymbol: .shuffle)
                Text("Shuffle")
            }
            .frame(width: 120, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
            .disabled(true)
        }
    }
}

private struct SongList: View {
    var songs: [Song]

    var body: some View {
        LazyVStack {
            ForEach(songs) { song in
                SongEntry(song: song)
                    .padding(.leading)
                    .padding(.trailing)
                    .font(.title3)

                Divider()
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            }
        }
    }
}

private struct SongEntry: View {
    var song: Song

    var body: some View {
        HStack {
            Text("\(song.index)")
                .frame(minWidth: 30)

            Text(song.name)
                .lineLimit(1)

            Spacer(minLength: 10)

            SongActions()
        }
        .frame(height: 40)
    }
}

private struct SongActions: View {
    let isDownloaded = true
    let isFavorite = true

    var body: some View {
        let downloadedIcon: SFSymbol = isDownloaded ? .checkmarkCircle : .arrowDownCircle
        let likedIcon: SFSymbol = isFavorite ? .heartFill : .heart

        Group {
            Button {
                // Song like action
            } label: {
                Image(systemSymbol: likedIcon)
            }
            .disabled(true)

            Button {
                // Song download action
            } label: {
                Image(systemSymbol: downloadedIcon)
            }
            .disabled(true)
        }
        .frame(width: 25)
    }
}

struct AlbumDetailScreen: View {

    @Environment(\.api)
    var api

    @State
    private var songs: [Song] = []

    @State
    private var isLoading = true

    var album: Album

    var body: some View {
        let downloadedIcon: SFSymbol = album.isDownloaded ? .checkmarkCircle : .arrowDownCircle
        let likedIcon: SFSymbol = album.isFavorite ? .heartFill : .heart

        ScrollView {
            VStack {
                AlbumHeading(album: album)

                AlbumActions()
                    .padding(.bottom, 30)

                SongList(
                    songs: songs
                )
                .padding(.bottom, 10)
                .overlay(loadingOverlay)
            }
        }
        .toolbar(content: {
            ToolbarItem(content: {
                Button {
                    // Album like button
                } label: {
                    Image(systemSymbol: likedIcon)
                }
                .disabled(true)
            })

            ToolbarItem(content: {
                Button {
                    // Album download action
                } label: {
                    Image(systemSymbol: downloadedIcon)
                }
                .disabled(true)
            })
        })
        .onAppear {
            Task {
                isLoading = true

                // Overdramatize loading
                sleep(2)

                do {
                    songs = try await api.songService.getSongs(
                        with: "0f0edfcf31d64740bd577afe8e94b752",
                        for: album.id
                    )
                } catch {
                    songs = []
                }

                isLoading = false
            }
        }
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoading {
            ProgressView()
        }
    }
}

#if DEBUG
struct AlbumDetailScreen_Previews: PreviewProvider {
    static let album = Album(
        uuid: "abc",
        name: "Album name",
        artistName: "Artist name",
        isDownloaded: false,
        isFavorite: true
    )

    static let albumLong = Album(
        uuid: "xyz",
        name: "Very long album name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
        artistName: "Very long artist name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
        isDownloaded: false,
        isFavorite: true,
        songs: [
            Song(
                uuid: "asdf",
                index: 1,
                name: "Very long song name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation"
            )
        ]
    )
    
    static var previews: some View {
        AlbumDetailScreen(album: album)
            .environment(\.api, .preview)
        AlbumDetailScreen(album: albumLong)
    }
}
#endif
