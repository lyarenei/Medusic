import SFSafeSymbols
import SwiftUI

struct SongEntryComponent: View {
    var song: Song

    var showAlbumOrder = false
    var showArtwork = true
    var showAction = true
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
                self.album = await AlbumRepository.shared.getAlbum(by: song.parentId)
            }

            if showAction {
                Spacer(minLength: 10)
                PrimaryActionButton(for: song.uuid)
                    .font(.title2)
                    .frame(width: 30)
            }
        }
        .frame(height: 40)
        .contextMenu { ContextOptions(item: song) }
    }
}

#if DEBUG
struct SongEntryComponent_Previews: PreviewProvider {
    static var previews: some View {
        LazyVStack {
            SongEntryComponent(song: PreviewData.songs[0])
                .padding(.leading)
                .padding(.trailing)
                .font(.title3)
        }
    }
}
#endif

private struct ContextOptions: View  {
    let item: Song

    var body: some View {
        DownloadButton(for: item.uuid, showText: true)

        FavoriteButton(isFavorite: false)

        Button {

        } label: {
            Image(systemSymbol: .textInsert)
            Text("Play next")
        }

        Button {
            
        } label: {
            Image(systemSymbol: .textAppend)
            Text("Play last")
        }
    }
}
