import SwiftUI

struct ArtistDetailScreen: View {
    private let artist: Artist

    init(artist: Artist) {
        self.artist = artist
    }

    var body: some View {
        VStack {
            header
            albums
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 15) {
            ArtworkComponent(itemId: artist.id)
                .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 10) {
                Text(artist.name)
                    .font(.title2)
                    .multilineTextAlignment(.leading)

                Text("0 albums, 0 minutes")
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var albums: some View {
        List {
            ForEach(0..<15) { idx in
                Label {
                    Text("Album \(idx)")
                        .font(.title3)
                } icon: {
                    Image(systemSymbol: .photoOnRectangleAngled)
                        .resizable()
                        .scaledToFit()
                }
                .labelStyle(.titleAndIcon)
                .frame(height: 40)
            }
        }
        .listStyle(.plain)
    }
}

#if DEBUG
// swiftlint:disable all
struct ArtistDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        ArtistDetailScreen(artist: PreviewData.artists.first!)
    }
}
// swiftlint:enable all
#endif
