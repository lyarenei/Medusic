import SwiftUI

struct AlbumView: View {
    
    var albumName: String
    var artistName: String
    
    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "")
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
                    
                    Text(artistName)
                        .font(.title2)
                }
                
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .frame(width: 120, height: 37)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 1.0))
                    )
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "shuffle")
                        Text("Shuffle")
                    }
                    .frame(width: 120, height: 37)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 1.0))
                    )
                }
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

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView(albumName: "Album name", artistName: "Artist name")
    }
}
