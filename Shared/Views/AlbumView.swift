import SwiftUI
import Kingfisher

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
                
            } label: {
                Image(systemSymbol: .playFill)
                Text("Play")
            }
            .frame(width: 120, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
            
            Button {
                
            } label: {
                Image(systemSymbol: .shuffle)
                Text("Shuffle")
            }
            .frame(width: 120, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
        }
    }
}

struct AlbumView: View {
    
    var album: Album
    
    var body: some View {
        ScrollView {
            VStack {
                AlbumHeading(
                    albumName: album.name,
                    artistName: album.artistName
                )
                
                AlbumActions()
                    .padding(.bottom, 30)
                
                LazyVStack {
                    ForEach(0..<15) {idx in
                        HStack {
                            Text("\(idx)")
                            Text("foo")
                        }
                    }
                }
                .padding(.bottom, 10)
            }
        }
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
