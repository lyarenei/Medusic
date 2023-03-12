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
    var song: Song

    var showAlbumOrder = false
    var showArtwork = true
    var showActions = true

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

            Text(song.name)
                .lineLimit(1)

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
        parentId: "someId"
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
