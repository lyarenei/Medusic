import SFSafeSymbols
import SwiftUI

private struct SongActions: View {
    @State
    private var isDownloaded = false

    @State
    private var isFavorite = false

    var song: Song

    var body: some View {
        HStack(spacing: 10) {
            FavoriteButton(isFavorite: $isFavorite)
                .disabled(true)

            DownloadButton(isDownloaded: $isDownloaded)
                .disabled(true)
        }
        .frame(minWidth: 25)
        .onAppear { self.isFavorite = self.song.isFavorite }
    }
}

struct SongEntryComponent: View {
    @StateObject
    private var albumRepo = AlbumRepository(store: .albums)

    var song: Song

    var showAlbumOrder = false
    var showArtwork = true
    var showActions = true
    var showAlbumName = false

    @State
    private var album: Album?

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

                if let albumName = album?.name, showAlbumName {
                    Text(albumName)
                        .lineLimit(1)
                        .font(.footnote)
                }
            }
            .backport.task {
                guard showAlbumName else { return }
                self.album = await albumRepo.getAlbum(by: song.parentId)
            }

            if showActions {
                Spacer(minLength: 10)
                SongActions(song: song)
                    .font(.title2)
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
