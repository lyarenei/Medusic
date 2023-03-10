import Kingfisher
import SwiftUI

private struct AlbumHeading: View {
    var albumImageUrl: URL?
    var albumName: String
    var artistName: String

    var body: some View {
        KFImage(albumImageUrl)
            .resizable()
            .frame(width: 230.0, height: 230)
            .overlay(
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
        VStack {
            Text(albumName)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text(artistName)
                .font(.title2)
                .multilineTextAlignment(.center)
        }
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
            ForEach(1 ..< 15) { idx in
                SongEntry(
                    index: idx,
                    name: "Ultra long song name which can't possibly fit on phone screen \(idx)"
                )
                .padding(.leading)
                .padding(.trailing)
                .font(.callout)
            }
        }
    }
}

private struct SongEntry: View {
    var index: Int
    var name: String

    var body: some View {
        HStack {
            Text("\(index)")
                .frame(minWidth: 30)

            Text(name)
                .lineLimit(1)

            Spacer(minLength: 10)

            SongActions()
        }
        .frame(height: 30)
        .overlay(
            Rectangle()
                .frame(
                    width: nil,
                    height: 1,
                    alignment: .bottom
                )
                .foregroundColor(Color.gray),
            alignment: .bottom
        )
    }
}

private struct SongActions: View {
    let isLiked = true

    var body: some View {
        Group {
            Button {
                // Song like action
            } label: {
                if isLiked {
                    Image(systemSymbol: .heartFill)
                } else {
                    Image(systemSymbol: .heart)
                }
            }
            .disabled(true)

            Button {
                // Song download action
            } label: {
                Image(systemSymbol: .arrowDownCircle)
            }
            .disabled(true)
        }
        .frame(width: 25)
    }
}

struct AlbumView: View {
    var album: Album
    var songs: [Song] = []

    var body: some View {
        ScrollView {
            VStack {
                AlbumHeading(
                    albumName: album.name,
                    artistName: album.artistName
                )

                AlbumActions()
                    .padding(.bottom, 30)

                SongList(
                    songs: songs
                )
                .padding(.bottom, 10)
            }
        }
        .toolbar(content: {
            ToolbarItem(content: {
                Button {
                    // Album download action
                } label: {
                    Image(systemSymbol: .arrowDownCircle)
                }
                .disabled(true)
            })
        })
    }
}

#if DEBUG
struct AlbumView_Previews: PreviewProvider {
    static let album = Album(uuid: "", name: "Name", artistName: "Artist")
    static var previews: some View {
        AlbumView(album: album)
    }
}
#endif
