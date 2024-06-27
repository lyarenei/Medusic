import SwiftUI

struct ArtistMenuOptions: View {
    let artist: ArtistDto

    var body: some View {
        FavoriteButton(artistId: artist.id, isFavorite: artist.isFavorite)
    }
}

struct ArtistContextMenu: ViewModifier {
    let artist: ArtistDto

    func body(content: Content) -> some View {
        content
            .contextMenu { ArtistMenuOptions(artist: artist) }
    }
}

extension View {
    func artistContextMenu(for artist: ArtistDto) -> some View {
        modifier(ArtistContextMenu(artist: artist))
    }
}
