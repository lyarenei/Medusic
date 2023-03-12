import SFSafeSymbols
import SwiftUI

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
        .frame(minWidth: 25)
    }
}

struct SongEntryComponent: View {
    @Environment(\.api)
    var api

    var song: Song

    var showAlbumOrder = false
    var showArtwork = true
    var showActions = true
    var showAlbumName = false

    @State
    private var albumName = ""

    var body: some View {
        HStack {
            if showAlbumOrder {
                Text("\(song.index)")
                    .frame(minWidth: 30)
            }

            if showArtwork {
                // TODO: Enable when able to do concurrent requests
                // ArtworkComponent(itemId: song.parentId)
                Image(systemSymbol: .photo)
                    .frame(maxWidth: 40)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(song.name)
                    .lineLimit(1)

                if showAlbumName {
                    // TODO: change to albumName
                    Text(song.name)
                        .lineLimit(1)
                        .font(.footnote)
                }
            }
            .backport.task {
                do {
                    if showAlbumName {
                        // TODO: implement when fetching/caching is sorted out
                        // albumName = try await api.albumService.getAlbum(by: song.parentId).name
                    }
                } catch {
                    print("Error when detting album info: \(error)")
                }
            }

            if showActions {
                Spacer(minLength: 10)
                SongActions()
            }
        }
        .frame(height: 40)
    }
}

#if DEBUG
struct SongEntryComponent_Previews: PreviewProvider {
    static var song = Song(
        uuid: "asdf",
        index: 1,
        name: "Very long song name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
        parentId: "someId",
        isDownloaded: false,
        isFavorite: false
    )

    static var previews: some View {
        LazyVStack {
            SongEntryComponent(song: song)
                .padding(.leading)
                .padding(.trailing)
                .font(.title3)
        }
    }
}
#endif
