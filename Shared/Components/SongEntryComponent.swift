import Combine
import SFSafeSymbols
import SwiftUI

private struct SongActions: View {
    @State
    var isDownloaded = false

    @State
    var isFavorite = false

    var body: some View {
        Group {
            FavoriteButton(isFavorite: $isFavorite)
                .disabled(true)

            DownloadButton(isDownloaded: $isDownloaded)
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
    private var album = Album.empty()

    @State
    private var lifetimeCancellables: Cancellables = []

    var body: some View {
        HStack {
            if showAlbumOrder {
                Text("\(song.index)")
                    .frame(minWidth: 30)
            }

            if showArtwork {
                ArtworkComponent(itemId: song.uuid)
                    .frame(maxWidth: 40)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(song.name)
                    .lineLimit(1)

                if showAlbumName {
                    Text(album.name)
                        .lineLimit(1)
                        .font(.footnote)
                }
            }
            .backport.task {
                guard showAlbumName else { return }
                api.services.albumService.getAlbum(by: song.parentId)
                    .catch { error -> Empty<Album, Never> in
                        print("Failed to fetch album:", error)
                        return Empty()
                    }
                    .assign(to: \.album, on: self)
                    .store(in: &lifetimeCancellables)
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
